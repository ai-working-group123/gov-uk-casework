#!/usr/bin/env ruby
# Full pipeline test: scrape a URL → analyse → generate.
# Usage:
#   ruby test_scrape_and_analyse.rb "https://www.gov.uk/skilled-worker-visa"
#   ruby test_scrape_and_analyse.rb   # uses a default test URL

require "bundler/setup"
require "dotenv"
require "openai"
require "nokogiri"
require "net/http"
require "uri"
require "json"
require "fileutils"
require_relative "helpers"

Dotenv.load(File.join(__dir__, "..", ".env"))

# ── Scraper ──────────────────────────────────────────────────

def fetch_page(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == "https"
  http.open_timeout = 10
  http.read_timeout = 10

  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "GovUK-Casework-Builder/1.0 (hackathon prototype)"

  response = http.request(request)
  raise "HTTP #{response.code}: #{response.message}" unless response.is_a?(Net::HTTPSuccess)

  Nokogiri::HTML(response.body)
end

def extract_text(doc)
  # Clone so we don't mutate the original (needed if we extract links first)
  clean = doc.dup
  clean.css("footer, header, script, style, noscript, .cookie-banner, #cookie-banner, .govuk-breadcrumbs, .gem-c-print-link, .gem-c-pagination, .gem-c-Related-content, .govuk-footer, .govuk-header").each(&:remove)

  main = clean.at_css("main") || clean.at_css("[role='main']") || clean.at_css("article") || clean.at_css("body")
  main.text.gsub(/\s+/, " ").gsub(/\n{3,}/, "\n\n").strip
end

def discover_subpages(doc, base_url)
  base_uri = URI.parse(base_url)
  base_path = base_uri.path.chomp("/")

  # Extract links BEFORE removing nav — GOV.UK guide navigation is in nav/sidebar
  links = doc.css("a[href]").filter_map do |a|
    href = a["href"].to_s.strip
    href = "#{base_uri.scheme}://#{base_uri.host}#{href}" if href.start_with?("/")
    next unless href.start_with?("#{base_uri.scheme}://#{base_uri.host}")

    link_path = URI.parse(href).path.chomp("/")
    next unless link_path.start_with?(base_path + "/")
    # Skip print page, anchors, deeply nested
    next if link_path.end_with?("/print")
    remaining = link_path.sub(base_path, "")
    next unless remaining.count("/") == 1

    { url: href, title: a.text.strip }
  end

  links.uniq { |l| l[:url] }
end

# Priority pages contain the most casework-relevant info
PRIORITY_SLUGS = %w[
  documents-you-must-provide your-job how-much-it-costs
  knowledge-of-english when-you-can-be-paid-less
  apply-from-outside-the-uk
].freeze

def scrape(url)
  puts "🌐 Scraping: #{url}"

  doc = fetch_page(url)
  main_text = extract_text(doc)
  puts "📄 Main page: #{main_text.length} chars"

  subpages = discover_subpages(doc, url)
  all_sections = [ { title: "Overview", text: main_text, priority: true } ]

  if subpages.any?
    # Sort: priority pages first
    subpages.sort_by! do |sp|
      slug = URI.parse(sp[:url]).path.split("/").last
      idx = PRIORITY_SLUGS.index(slug)
      idx || 999
    end

    puts "📑 Found #{subpages.length} sub-pages"
    subpages.each do |sp|
      begin
        sub_doc = fetch_page(sp[:url])
        sub_text = extract_text(sub_doc)
        slug = URI.parse(sp[:url]).path.split("/").last
        is_priority = PRIORITY_SLUGS.include?(slug)
        puts "   #{is_priority ? '⭐' : '✓'} #{sp[:title]} (#{sub_text.length} chars)"
        all_sections << { title: sp[:title], text: sub_text, priority: is_priority }
        sleep 0.3
      rescue => e
        puts "   ✗ #{sp[:title]}: #{e.message}"
      end
    end
  end

  # Smart budget: priority pages get 2x allocation
  total_budget = 15_000
  priority_sections = all_sections.select { |s| s[:priority] }
  normal_sections = all_sections.reject { |s| s[:priority] }
  priority_weight = priority_sections.length * 2
  normal_weight = normal_sections.length
  total_weight = priority_weight + normal_weight
  per_unit = total_budget / [ total_weight, 1 ].max

  combined = all_sections.map do |s|
    budget = s[:priority] ? per_unit * 2 : per_unit
    text = s[:text].length > budget ? s[:text][0, budget] : s[:text]
    "## #{s[:title]}\n#{text}"
  end.join("\n\n")

  puts "📄 Total scraped: #{combined.length} chars across #{all_sections.length} sections"
  combined
end

# ── Prompts ──────────────────────────────────────────────────

ANALYSIS_PROMPT = <<~PROMPT
  You are an expert UK government process analyst specialising in casework system design.
  Given scraped content from a government webpage describing a process (e.g. visa, licence, permit), produce a deep structured analysis.

  Think like a caseworker who will process these applications daily. Extract EVERYTHING.

  CRITICAL RULES:
  - Extract EVERY number: salary thresholds, fee amounts (with duration tiers), savings requirements, time limits
  - List EVERY document by its specific name (e.g. "IELTS/TOEFL certificate" not "proof of English", "TB test certificate" not "medical document")
  - Distinguish between application tracks: inside UK vs outside UK, new vs extension vs switch
  - Include conditional logic: when fees/requirements differ based on circumstances
  - Capture the "28 days" type rules, validity periods, and deadlines
  - Note what happens for healthcare/education workers vs standard applicants

  Return a JSON object:

  {
    "name": "Short case type name",
    "description": "One-sentence description of the process",
    "applicant_type": "Who applies (be specific)",
    "caseworker_type": "Which team/unit decides",
    "application_tracks": [
      {
        "track": "e.g. New application from outside UK",
        "fee_gbp": 819,
        "fee_detail": "£819 for up to 3 years, £1,618 for more than 3 years",
        "processing_time": "3 weeks standard",
        "priority_available": true,
        "additional_requirements": ["Anything specific to this track"]
      }
    ],
    "eligibility_criteria": [
      {
        "criterion": "Specific check description with thresholds/numbers",
        "type": "pass_fail | conditional | threshold | subjective",
        "details": "Exact figures: £41,700 or going rate, whichever higher",
        "exemptions": "Who is exempt and under what conditions",
        "lower_threshold": "If there's a reduced requirement, what is it and who qualifies"
      }
    ],
    "evidence_requirements": [
      {
        "name": "Exact document name (e.g. 'IELTS Academic certificate', 'TB test certificate')",
        "required": true,
        "conditional_on": "When this is needed vs when it's waived",
        "source": "Applicant | Employer | Third party | Government system",
        "verification_method": "How a caseworker checks this",
        "validity_period": "How long the document is valid",
        "notes": "Accepted formats, specific rules (e.g. bank statements must show funds held for 28 consecutive days)"
      }
    ],
    "workflow_stages": [
      {
        "stage": "Stage name",
        "description": "What happens",
        "typical_duration": "e.g. 1-3 days",
        "decision_points": ["What can happen at this stage"],
        "next_stages": ["Possible next stages"],
        "caseworker_actions": ["Specific things the caseworker does"]
      }
    ],
    "possible_outcomes": [
      "Granted for up to 5 years",
      "Granted with conditions",
      "Refused - eligibility not met",
      "Refused - insufficient evidence",
      "Refused - genuineness concerns",
      "Withdrawn by applicant"
    ],
    "typical_timeline": {
      "outside_uk": "3 weeks",
      "inside_uk": "8 weeks",
      "priority_service": "5 working days (if available and fee paid)",
      "super_priority": "Next working day (if available)"
    },
    "communication_touchpoints": [
      {
        "trigger": "What triggers this communication",
        "channel": "email | letter | SMS | portal notification",
        "recipient": "applicant | employer | representative",
        "content_summary": "What the message says",
        "includes_deadline": true,
        "deadline_days": 28
      }
    ],
    "risk_indicators": [
      {
        "indicator": "What raises concern",
        "severity": "low | medium | high",
        "caseworker_action": "What the caseworker should do"
      }
    ],
    "related_processes": ["Other case types this links to, e.g. Health and Care Worker visa, Indefinite Leave to Remain"],
    "confidence_scores": {
      "eligibility": 0.8,
      "evidence": 0.7,
      "workflow": 0.6,
      "timeline": 0.5,
      "fees": 0.3
    },
    "clarifying_questions": [
      {
        "question": "Specific question",
        "element": "Which section",
        "options": ["Possible answers"],
        "why": "Why"
      }
    ],
    "data_gaps": ["List anything the scraped content doesn't cover that a caseworker would need to know"]
  }

  Only include clarifying_questions for elements where confidence < 0.7.
  NEVER generalise — if you found a specific number, include it. If you didn't find something, say so in data_gaps.
  Return ONLY valid JSON.
PROMPT

GENERATION_PROMPT = <<~PROMPT
  You are an expert government service designer building a casework management system.
  Given a structured analysis of a government process, generate a production-ready case type configuration as structured JSON.

  The system has these Rails models and enums:
  - Case (status: submitted | assigned | in_review | awaiting_evidence | ready_for_decision | decided_approved | decided_refused | withdrawn)
    (priority: low | medium | high | urgent)
  - Action (action_type: chase_evidence | review_documents | make_decision | send_correspondence | escalate | schedule_interview)
    (status: pending | in_progress | completed | blocked | cancelled)
  - Evidence (evidence_type: passport | english_language | tb_certificate | bank_statements | sponsorship_certificate | biometrics | employer_letter | accommodation_proof | relationship_evidence | police_clearance)
    (status: not_received | received | under_review | accepted | rejected)
  - EvidenceRequest (status: draft | sent | partially_fulfilled | fulfilled | expired)
  - EvidenceRequestItem (submission_method: digital | physical | either) (status: pending | received | accepted | rejected)
  - Correspondence (channel: letter | email | portal | sms) (direction: outbound | inbound)
  - PolicyReference (code, title, govuk_url, criteria, case_types, policy_area)

  CRITICAL RULES:
  1. policy_references govuk_url: ONLY use URLs from the analysis input. If none found, set to null. NEVER fabricate URLs.
  2. state_transitions: decided_approved and decided_refused are SEPARATE states — always separate entries.
  3. Evidence checklist: at least 8 items. Cover ALL documents from the analysis.
  4. Correspondence templates: include specific policy reference codes and appeal/review deadlines.
  5. Risk scoring: include immigration-specific factors (refusals, overstays, sponsor compliance, document authenticity, financial irregularities).
  6. ALL enum values MUST match the Rails enums listed above exactly.

  Generate this JSON structure:

  {
    "name": "Case type name",
    "slug": "snake_case_slug",
    "description": "One-sentence description",
    "organisation": "Organisation name",
    "default_sla_days": 21,
    "priority_sla_days": 5,

    "decision_gates": [
      {
        "gate_number": 1,
        "title": "Short gate name e.g. Application completeness",
        "check": "What is being checked — specific threshold or criterion",
        "policy_ref": "SW-SPONSOR-01",
        "pass_action": "next_gate",
        "fail_action": "refuse | chase_evidence | check_exemption",
        "fail_reason": "Specific refusal reason if fail_action is refuse",
        "exemptions": ["List any exemptions that allow proceeding despite failure"]
      }
    ],

    "state_transitions": [
      {
        "from_state": "submitted",
        "trigger": "Application received",
        "to_state": "assigned",
        "auto_actions": ["notify_caseworker", "log_receipt"],
        "sla_impact": "starts"
      }
    ],

    "evidence_checklist": [
      {
        "name": "Certificate of Sponsorship",
        "evidence_type": "sponsorship_certificate",
        "required": true,
        "conditional_on": null,
        "verification_method": "Cross-check against Home Office sponsor records",
        "auto_check": true,
        "policy_ref": "SW-SPONSOR-02",
        "submission_method": "digital",
        "validity_period": null
      }
    ],

    "correspondence_templates": [
      {
        "name": "Acknowledgement of Application",
        "trigger": "on_submission",
        "channel": "email",
        "subject": "{{ case_type }} application received – {{ case_reference }}",
        "body": "Full template text with {{ variable }} placeholders. Use realistic GOV.UK tone. Include next steps, expected timeline, and standard Home Office footer."
      },
      {
        "name": "Evidence Request",
        "trigger": "on_evidence_gap",
        "channel": "email",
        "subject": "Further information required – {{ case_reference }}",
        "body": "Template with deadline (28 days), numbered evidence list, consequences of not responding, how to submit."
      },
      {
        "name": "Decision: Approved",
        "trigger": "on_approve",
        "channel": "letter",
        "subject": "Decision on your {{ case_type }} application – {{ case_reference }}",
        "body": "Template with grant dates, conditions, what applicant can/cannot do, policy references."
      },
      {
        "name": "Decision: Refused",
        "trigger": "on_refuse",
        "channel": "letter",
        "subject": "Decision on your {{ case_type }} application – {{ case_reference }}",
        "body": "Template with specific refusal reasons, policy refs, appeal rights with deadlines (28 days outside UK, 14 days inside UK), administrative review option."
      },
      {
        "name": "Chase for Missing Evidence",
        "trigger": "on_evidence_deadline_approaching",
        "channel": "email",
        "subject": "Reminder: outstanding documents – {{ case_reference }}",
        "body": "Template listing outstanding items, deadline, consequences."
      }
    ],

    "risk_factors": [
      {
        "name": "Previous visa refusals",
        "score": 6,
        "category": "immigration_history",
        "trigger": "Specific condition that activates this risk factor",
        "caseworker_action": "What the caseworker should do"
      }
    ],

    "risk_thresholds": {
      "low": [0, 3],
      "medium": [4, 6],
      "high": [7, 10]
    },

    "risk_escalation": {
      "standard_processing": [0, 10],
      "enhanced_checks": [11, 20],
      "senior_review": [21, null]
    },

    "auto_assignment_rules": [
      {
        "condition": "Description of when this rule applies",
        "assign_to": "specialist | senior | standard",
        "priority_boost": false,
        "reason": "Why this routing exists"
      }
    ],

    "policy_references": [
      {
        "code": "SW-SPONSOR-01",
        "title": "Short title",
        "policy_area": "sponsorship",
        "govuk_url": null,
        "criteria": "What this reference requires"
      }
    ]
  }

  Make everything SPECIFIC to the process from the analysis — no generic placeholders.
  Use realistic GOV.UK language and tone in correspondence templates.
  For policy_references: set govuk_url to null unless you have a REAL URL from the analysis.
  Return ONLY valid JSON.
PROMPT

RECONCILE_PROMPT = <<~PROMPT
  You are an expert government service designer maintaining a casework management system.

  You will receive two JSON configs:
  1. ORIGINAL CONFIG — the LLM-generated config before edits
  2. EDITED CONFIG — the version a human admin has modified

  Your job is to RECONCILE the edits. The admin's changes are intentional and must be kept.
  But their edits may have knock-on effects that need propagating. For example:

  - If they REMOVED an evidence item, remove it from decision_gates that reference it,
    update any correspondence templates that mention it, and remove its policy_ref if orphaned.
  - If they ADDED a new evidence item, add a matching decision gate for it and ensure
    the evidence_type matches a valid enum (passport | english_language | tb_certificate |
    bank_statements | sponsorship_certificate | biometrics | employer_letter |
    accommodation_proof | relationship_evidence | police_clearance).
  - If they CHANGED SLA days, update any correspondence templates that reference timelines.
  - If they CHANGED risk scores or thresholds, update auto_assignment_rules to match.
  - If they MODIFIED decision gates (reordered, removed, added), renumber gate_numbers
    sequentially and fix all pass_action/fail_action references.
  - If they CHANGED state transitions, ensure correspondence template triggers still
    reference valid states.
  - If they ADDED or REMOVED policy references, update all sections that reference those codes.

  RULES:
  1. PRESERVE all admin edits exactly — never undo their changes.
  2. Only ADD or MODIFY other sections to maintain consistency with the edits.
  3. Keep the same JSON structure as the input.
  4. All enum values must match Rails enums:
     - Case status: submitted | assigned | in_review | awaiting_evidence | ready_for_decision | decided_approved | decided_refused | withdrawn
     - Action type: chase_evidence | review_documents | make_decision | send_correspondence | escalate | schedule_interview
     - Evidence type: passport | english_language | tb_certificate | bank_statements | sponsorship_certificate | biometrics | employer_letter | accommodation_proof | relationship_evidence | police_clearance
     - Correspondence channel: letter | email | portal | sms
  5. govuk_url: keep null unless a real URL exists. NEVER fabricate URLs.
  6. Return the COMPLETE reconciled config, not just the changes.

  Return ONLY valid JSON.
PROMPT

# ── Main ─────────────────────────────────────────────────────

skip_questions = ARGV.delete("--skip-questions")
url = ARGV[0] || "https://www.swansea.gov.uk/article/5075/Apply-for-a-black-bag-limit-exemption"
client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

# Step 1: Scrape
scraped_text = scrape(url)
puts "\n--- Scraped Content (first 500 chars) ---"
puts scraped_text[0, 500]
puts "..."

# Step 2: Analyse
puts "\n🔍 Step 2: Analysing process..."
start = Time.now

analysis_response = client.chat(
  parameters: {
    model: "gpt-5.4",
    messages: [
      { role: "system", content: ANALYSIS_PROMPT },
      { role: "user", content: "Analyse this government process from the scraped GOV.UK content below. Extract every specific detail — numbers, thresholds, dates, fees, document names.\n\n#{scraped_text}" }
    ],
    max_completion_tokens: 8000,
    temperature: 0.2
  }
)

analysis_text = analysis_response.dig("choices", 0, "message", "content")
analysis = SandboxHelpers.parse_llm_json(analysis_text)
elapsed_analysis = (Time.now - start).round(2)

puts "✅ Analysis complete in #{elapsed_analysis}s"
puts "   Name: #{analysis['name']}"
puts "   Questions: #{analysis['clarifying_questions']&.length || 0}"

# Show workflow if present
if analysis["workflow_stages"]&.any?
  puts "\n📋 Workflow Stages:"
  analysis["workflow_stages"].each_with_index do |s, i|
    puts "   #{i + 1}. #{s['stage']} (#{s['typical_duration'] || '?'})"
  end
end

# Show data gaps if present
if analysis["data_gaps"]&.any?
  puts "\n⚠️  Data Gaps (not found in source):"
  analysis["data_gaps"].each { |gap| puts "   • #{gap}" }
end

# Step 2b: Interactive clarifying questions
answers = {}
if analysis["clarifying_questions"]&.any? && !skip_questions
  puts "\n" + "─" * 60
  puts "❓ CLARIFYING QUESTIONS"
  puts "─" * 60
  puts "The analysis has low confidence on some elements."
  puts "Answer each question to improve the generated config."
  puts "Press Enter to skip a question, or type 's' to skip all.\n\n"

  analysis["clarifying_questions"].each_with_index do |q, i|
    puts "   #{i + 1}/#{analysis['clarifying_questions'].length}. #{q['question']}"
    puts "      Element: #{q['element']}" if q["element"]
    puts "      Why: #{q['why']}" if q["why"]
    if q["options"]&.any?
      q["options"].each_with_index { |opt, j| puts "      #{j + 1}) #{opt}" }
      puts "      Enter a number, type your own answer, or press Enter to skip:"
    else
      puts "      Type your answer, or press Enter to skip:"
    end
    print "      > "
    input = $stdin.gets&.strip

    break if input&.downcase == "s"

    unless input.nil? || input.empty?
      # If they entered a number matching an option, use the option text
      if q["options"] && input.match?(/^\d+$/) && (idx = input.to_i - 1) >= 0 && idx < q["options"].length
        answer_text = q["options"][idx]
      else
        answer_text = input
      end
      answers[q["element"] || "question_#{i + 1}"] = answer_text
      puts "      ✅ Recorded: #{answer_text}"
    else
      puts "      ⏭️  Skipped"
    end
    puts
  end

  if answers.any?
    puts "\n📝 #{answers.length} answer(s) recorded — merging into analysis..."
    # Merge answers into the analysis so the generation prompt has enriched context
    analysis["admin_answers"] = answers
    analysis["clarifying_questions"].each do |q|
      element = q["element"]
      next unless element && answers[element]
      q["admin_answer"] = answers[element]
      q["resolved"] = true
    end
  else
    puts "\n⏭️  All questions skipped — proceeding with best judgement."
  end
else
  if analysis["clarifying_questions"]&.any? && skip_questions
    puts "\n⏭️  #{analysis['clarifying_questions'].length} question(s) skipped (--skip-questions flag)."
  else
    puts "\n✅ No clarifying questions — analysis is high-confidence."
  end
end

# Step 3: Generate
puts "\n⚙️  Step 3: Generating case type config..."
start = Time.now

generation_context = JSON.pretty_generate(analysis)
if answers.any?
  generation_context += "\n\nADMIN ANSWERS TO CLARIFYING QUESTIONS:\n"
  answers.each { |element, answer| generation_context += "- #{element}: #{answer}\n" }
end

gen_response = client.chat(
  parameters: {
    model: "gpt-5.4",
    messages: [
      { role: "system", content: GENERATION_PROMPT },
      { role: "user", content: "Generate a production-ready case type config from this analysis. Be detailed and specific — this will drive a real casework system.\n\n#{generation_context}" }
    ],
    max_completion_tokens: 16000,
    temperature: 0.2
  }
)

gen_text = gen_response.dig("choices", 0, "message", "content")
config = SandboxHelpers.parse_llm_json(gen_text)
elapsed_gen = (Time.now - start).round(2)

puts "✅ Generation complete in #{elapsed_gen}s"

# Display results
puts "\n" + "=" * 60
puts "GENERATED CASE TYPE CONFIG"
puts "=" * 60
puts "Name: #{config['name']}"
puts "Slug: #{config['slug']}"
puts "Org:  #{config['organisation']}"
puts "SLA:  #{config['default_sla_days']} days (priority: #{config['priority_sla_days'] || 'N/A'} days)"

if config["decision_gates"]&.any?
  puts "\n#{'─' * 60}"
  puts "📄 DECISION GATES (#{config['decision_gates'].length})"
  puts "─" * 60
  config["decision_gates"].each do |g|
    puts "   Gate #{g['gate_number']}: #{g['title']}"
    puts "      Check: #{g['check']}"
    puts "      Pass → #{g['pass_action']} | Fail → #{g['fail_action']}"
  end
end

if config["state_transitions"]&.any?
  puts "\n#{'─' * 60}"
  puts "📄 STATE TRANSITIONS (#{config['state_transitions'].length})"
  puts "─" * 60
  config["state_transitions"].each do |t|
    puts "   #{t['from_state']} → #{t['to_state']} (#{t['trigger']})"
  end
end

if config["evidence_checklist"]&.any?
  puts "\n#{'─' * 60}"
  puts "📄 EVIDENCE CHECKLIST (#{config['evidence_checklist'].length} items)"
  puts "─" * 60
  config["evidence_checklist"].each_with_index do |e, i|
    req = e["required"] ? "Required" : "Optional"
    puts "   #{i + 1}. #{e['name']} [#{req}] (#{e['evidence_type']})"
  end
end

if config["correspondence_templates"]&.any?
  puts "\n#{'─' * 60}"
  puts "📄 CORRESPONDENCE TEMPLATES (#{config['correspondence_templates'].length})"
  puts "─" * 60
  config["correspondence_templates"].each do |c|
    puts "   • #{c['name']} (#{c['trigger']}, #{c['channel']})"
  end
end

if config["risk_factors"]&.any?
  puts "\n#{'─' * 60}"
  puts "📄 RISK FACTORS (#{config['risk_factors'].length})"
  puts "─" * 60
  config["risk_factors"].each do |r|
    puts "   [#{r['score']}] #{r['name']} (#{r['category']})"
  end
end

if config["auto_assignment_rules"]&.any?
  puts "\n#{'─' * 60}"
  puts "📄 AUTO ASSIGNMENT RULES (#{config['auto_assignment_rules'].length})"
  puts "─" * 60
  config["auto_assignment_rules"].each do |r|
    puts "   → #{r['assign_to']}: #{r['condition']}"
  end
end

if config["policy_references"]&.any?
  puts "\n#{'─' * 60}"
  puts "📄 POLICY REFERENCES (#{config['policy_references'].length})"
  puts "─" * 60
  config["policy_references"].each do |pr|
    puts "  #{pr['code']}: #{pr['title']}"
  end
end

# Save outputs
FileUtils.mkdir_p(File.join(__dir__, "output"))
timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
File.write(File.join(__dir__, "output", "analysis_#{timestamp}.json"), JSON.pretty_generate(analysis))
config_path = File.join(__dir__, "output", "config_#{timestamp}.json")
File.write(config_path, JSON.pretty_generate(config))
puts "\n💾 Outputs saved to sandbox/output/"
puts "   analysis_#{timestamp}.json"
puts "   config_#{timestamp}.json"

# Token summary
a_usage = analysis_response["usage"]
g_usage = gen_response["usage"]
total_tokens = a_usage["total_tokens"] + g_usage["total_tokens"]
puts "\n----- Total Usage -----"
puts "Analysis:   #{a_usage['total_tokens']} tokens (#{elapsed_analysis}s)"
puts "Generation: #{g_usage['total_tokens']} tokens (#{elapsed_gen}s)"

# ── Step 4: Edit → Reconcile loop ────────────────────────────
unless skip_questions
  loop do
    puts "\n" + "─" * 60
    puts "✏️  STEP 4: REVIEW & EDIT"
    puts "─" * 60
    puts "The config has been saved to:"
    puts "   #{config_path}"
    puts
    puts "Open the file, make your changes (e.g. adjust SLA days, add/remove"
    puts "evidence items, tweak risk scores, edit correspondence templates),"
    puts "then come back here."
    puts
    puts "Options:"
    puts "   r  — Reconcile: re-run LLM to update decision flow based on your edits"
    puts "   d  — Done: accept the config as-is and finish"
    puts "   v  — View: print a summary of the current config"
    print "   > "
    choice = $stdin.gets&.strip&.downcase

    case choice
    when "d", nil, ""
      puts "\n✅ Config finalised."
      break

    when "v"
      current = JSON.parse(File.read(config_path))
      puts "\n📋 Current config: #{current['name']} (#{current['slug']})"
      puts "   SLA: #{current['default_sla_days']}d / priority: #{current['priority_sla_days']}d"
      puts "   Decision gates: #{current['decision_gates']&.length || 0}"
      puts "   State transitions: #{current['state_transitions']&.length || 0}"
      puts "   Evidence items: #{current['evidence_checklist']&.length || 0}"
      puts "   Correspondence templates: #{current['correspondence_templates']&.length || 0}"
      puts "   Risk factors: #{current['risk_factors']&.length || 0}"
      puts "   Assignment rules: #{current['auto_assignment_rules']&.length || 0}"
      puts "   Policy references: #{current['policy_references']&.length || 0}"

    when "r"
      # Read the (possibly edited) config back
      edited_json = File.read(config_path)
      begin
        edited_config = JSON.parse(edited_json)
      rescue JSON::ParserError => e
        puts "\n❌ Invalid JSON in config file: #{e.message}"
        puts "   Fix the JSON and try again."
        next
      end

      # Diff summary for the user
      changes = []
      changes << "SLA changed (#{config['default_sla_days']}→#{edited_config['default_sla_days']})" if edited_config["default_sla_days"] != config["default_sla_days"]
      changes << "priority SLA changed" if edited_config["priority_sla_days"] != config["priority_sla_days"]
      changes << "decision gates changed (#{config['decision_gates']&.length}→#{edited_config['decision_gates']&.length})" if edited_config["decision_gates"]&.length != config["decision_gates"]&.length
      changes << "evidence checklist changed (#{config['evidence_checklist']&.length}→#{edited_config['evidence_checklist']&.length})" if edited_config["evidence_checklist"]&.length != config["evidence_checklist"]&.length
      changes << "risk factors changed (#{config['risk_factors']&.length}→#{edited_config['risk_factors']&.length})" if edited_config["risk_factors"]&.length != config["risk_factors"]&.length
      changes << "correspondence templates changed" if edited_config["correspondence_templates"]&.length != config["correspondence_templates"]&.length
      changes << "assignment rules changed" if edited_config["auto_assignment_rules"]&.length != config["auto_assignment_rules"]&.length
      changes << "policy references changed" if edited_config["policy_references"]&.length != config["policy_references"]&.length

      if changes.empty?
        # Do a deep compare on JSON strings to detect value-level changes
        if JSON.pretty_generate(edited_config) == JSON.pretty_generate(config)
          puts "\n⚠️  No changes detected. Edit the file first, then reconcile."
          next
        else
          changes << "values modified (same structure)"
        end
      end

      puts "\n🔍 Detected changes:"
      changes.each { |c| puts "   • #{c}" }

      puts "\n🔄 Step 4b: Reconciling edits with LLM..."
      start = Time.now

      reconcile_response = client.chat(
        parameters: {
          model: "gpt-5.4",
          messages: [
            { role: "system", content: RECONCILE_PROMPT },
            { role: "user", content: "ORIGINAL CONFIG:\n#{JSON.pretty_generate(config)}\n\nEDITED CONFIG:\n#{JSON.pretty_generate(edited_config)}" }
          ],
          max_completion_tokens: 16000,
          temperature: 0.2
        }
      )

      reconcile_text = reconcile_response.dig("choices", 0, "message", "content")
      reconciled = SandboxHelpers.parse_llm_json(reconcile_text)
      elapsed_reconcile = (Time.now - start).round(2)

      r_usage = reconcile_response["usage"]
      total_tokens += r_usage["total_tokens"]

      puts "✅ Reconciliation complete in #{elapsed_reconcile}s (#{r_usage['total_tokens']} tokens)"

      # Update config and save
      config = reconciled
      File.write(config_path, JSON.pretty_generate(config))
      puts "💾 Updated config saved to #{config_path}"

      # Show summary
      puts "\n📋 Reconciled config:"
      puts "   Decision gates: #{config['decision_gates']&.length || 0}"
      puts "   State transitions: #{config['state_transitions']&.length || 0}"
      puts "   Evidence items: #{config['evidence_checklist']&.length || 0}"
      puts "   Correspondence templates: #{config['correspondence_templates']&.length || 0}"
      puts "   Risk factors: #{config['risk_factors']&.length || 0}"
      puts "   Assignment rules: #{config['auto_assignment_rules']&.length || 0}"
      puts "   Policy references: #{config['policy_references']&.length || 0}"

    else
      puts "   ⚠️  Unknown option '#{choice}'. Enter r, d, or v."
    end
  end
end

puts "\nTotal tokens used: #{total_tokens}"
