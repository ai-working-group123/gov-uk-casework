#!/usr/bin/env ruby
# Interactive pipeline: scrape → follow links → analyse → ask questions → generate.
# Simulates the real user experience step-by-step with pauses and decisions.
#
# Usage:
#   ruby interactive_pipeline.rb
#   ruby interactive_pipeline.rb "https://www.gov.uk/skilled-worker-visa"
#   ruby interactive_pipeline.rb "https://www.swansea.gov.uk/article/5075/Apply-for-a-black-bag-limit-exemption"

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

# ── Colours ──────────────────────────────────────────────────

module C
  def self.bold(s)    = "\e[1m#{s}\e[0m"
  def self.green(s)   = "\e[32m#{s}\e[0m"
  def self.yellow(s)  = "\e[33m#{s}\e[0m"
  def self.cyan(s)    = "\e[36m#{s}\e[0m"
  def self.red(s)     = "\e[31m#{s}\e[0m"
  def self.dim(s)     = "\e[2m#{s}\e[0m"
  def self.blue(s)    = "\e[34m#{s}\e[0m"
end

def divider(char = "─", width = 70)
  puts C.dim(char * width)
end

def step_header(num, title)
  puts
  divider("═")
  puts C.bold("  STEP #{num}: #{title}")
  divider("═")
  puts
end

def prompt_user(question, options: nil, default: nil)
  puts C.cyan("  #{question}")
  if options
    options.each_with_index do |opt, i|
      marker = (i + 1 == default) ? C.green("→") : " "
      puts "  #{marker} #{i + 1}) #{opt}"
    end
    puts C.dim("  Enter number (or press Enter for default #{default}):")
  end
  print C.yellow("  > ")
  input = STDIN.gets&.strip || ""
  if options
    idx = input.empty? ? (default ? default - 1 : 0) : (input.to_i - 1)
    idx = idx.clamp(0, options.length - 1)
    puts C.green("  ✓ Selected: #{options[idx]}")
    return options[idx]
  end
  input.nil? || input.empty? ? default : input
end

def wait_for_enter(msg = "Press Enter to continue...")
  print C.dim("\n  #{msg} ")
  STDIN.gets
end

# ── Scraper with link discovery ──────────────────────────────

def fetch_page(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == "https"
  http.open_timeout = 10
  http.read_timeout = 10
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "GovUK-Casework-Builder/1.0 (hackathon prototype)"
  response = http.request(request)
  raise "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)
  response.body
end

def scrape_page(url)
  html = fetch_page(url)
  doc = Nokogiri::HTML(html)
  doc.css("nav, footer, header, script, style, noscript, .cookie-banner, #cookie-banner, .govuk-breadcrumbs, .gem-c-related-navigation").each(&:remove)
  main = doc.at_css("main") || doc.at_css("[role='main']") || doc.at_css("article") || doc.at_css("body")

  # Extract links (for link discovery)
  base_uri = URI.parse(url)
  links = main.css("a[href]").map do |a|
    href = a["href"]
    text = a.text.strip
    next if text.empty? || href.start_with?("#", "javascript:", "mailto:")
    begin
      resolved = URI.join(base_uri, href).to_s
      { text: text[0, 80], url: resolved }
    rescue URI::InvalidURIError
      nil
    end
  end.compact.uniq { |l| l[:url] }

  text = main.text.gsub(/\s+/, " ").gsub(/\n{3,}/, "\n\n").strip
  { text: text[0, 5000], links: links, title: doc.at_css("title")&.text&.strip || url }
end

# ── LLM Client ───────────────────────────────────────────────

CLIENT = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
TOTAL_TOKENS = { prompt: 0, completion: 0 }

def llm_call(system_prompt, user_prompt, max_tokens: 2000)
  start = Time.now
  response = CLIENT.chat(
    parameters: {
      model: "gpt-4o",
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: user_prompt }
      ],
      max_tokens: max_tokens,
      temperature: 0.3
    }
  )
  elapsed = (Time.now - start).round(2)
  usage = response["usage"]
  TOTAL_TOKENS[:prompt] += usage["prompt_tokens"]
  TOTAL_TOKENS[:completion] += usage["completion_tokens"]
  content = response.dig("choices", 0, "message", "content")
  puts C.dim("  (#{elapsed}s · #{usage['total_tokens']} tokens)")
  content
end

# ── Prompts ──────────────────────────────────────────────────

LINK_RELEVANCE_PROMPT = <<~PROMPT
  You are helping build a casework system. Given a page about a government process and a list of links found on that page, identify which links would contain ADDITIONAL useful information for understanding:
  - Evidence/document requirements
  - Eligibility criteria
  - Decision-making process
  - Timelines/SLAs
  - Application steps

  Return a JSON array of objects: [{"url": "...", "reason": "why this link is useful"}]
  Maximum 5 links. Only include links that would add NEW information not already in the main page.
  Return ONLY valid JSON, no markdown fences.
PROMPT

ANALYSIS_PROMPT = <<~PROMPT
  You are an expert government process analyst. Given text from one or more pages describing a government or public sector process, produce a thorough analysis.

  Return a JSON object:
  {
    "name": "Short case type name",
    "description": "2-3 sentence description of the full process",
    "applicant_type": "Who applies",
    "caseworker_type": "Who reviews/decides",
    "evidence_requirements": [
      { "name": "Document/evidence name", "required": "mandatory|conditional|optional", "source": "Who provides", "condition": "When needed (if conditional)", "verification": "How to check it" }
    ],
    "eligibility_criteria": [
      { "criterion": "Check description", "type": "pass_fail|subjective|conditional", "fail_action": "refuse|request_more|escalate" }
    ],
    "decision_logic": [
      { "step": 1, "check": "Description", "yes": "proceed|approve", "no": "refuse|request_evidence|escalate" }
    ],
    "possible_outcomes": ["Approved", "Refused", ...],
    "typical_timeline_days": 14,
    "sla_source": "Where the SLA comes from",
    "communication_steps": [
      { "stage": "When", "channel": "email|letter|portal|phone", "content": "What", "template_needed": true|false }
    ],
    "edge_cases": ["Unusual scenarios the system should handle"],
    "confidence_scores": {
      "name": 0.9, "evidence": 0.5, "eligibility": 0.7, "decision_logic": 0.6, "timeline": 0.5, "communication": 0.4
    },
    "clarifying_questions": [
      {
        "question": "Specific question",
        "element": "Which part this clarifies",
        "options": ["Option A", "Option B", "Option C", "Other"],
        "why": "Why this matters",
        "impact": "What changes based on the answer"
      }
    ]
  }

  Rules:
  - Be thorough — extract EVERYTHING you can from the source text
  - Only ask clarifying_questions for elements with confidence < 0.7
  - Questions should be specific and actionable, not generic
  - Include edge cases you can infer (appeals, reapplication, expiry)
  - Decision logic should be a sequential checklist, not a tree
  - Return ONLY valid JSON
PROMPT

ENRICHMENT_PROMPT = <<~PROMPT
  You are an expert government process analyst. You previously analysed a process and asked clarifying questions. The admin has now answered them.

  Given:
  1. Your original analysis
  2. The questions and answers

  Produce an UPDATED analysis with the same JSON structure, incorporating the answers. Raise confidence scores where answers resolved ambiguity. Remove answered questions from clarifying_questions. Add any NEW questions that arise from the answers (if any).

  Return ONLY valid JSON with the same structure as the original analysis.
PROMPT

GENERATION_PROMPT = <<~PROMPT
  You are an expert government service designer. Given a thorough analysis of a government process, generate a complete case type configuration.

  Return a JSON object:
  {
    "name": "Case type name",
    "slug": "snake_case_slug",
    "description": "Description",
    "organisation": "Organisation name",
    "default_sla_days": 14,
    "decision_tree_md": "See format below",
    "state_transitions_md": "See format below",
    "evidence_requirements_md": "See format below",
    "correspondence_templates_md": "See format below",
    "risk_scoring_md": "See format below"
  }

  DECISION TREE FORMAT — use ASCII tree with box-drawing characters:
  ```
  START
  │
  ├─ Is [criterion]?
  │   ├─ NO → REFUSE (reason) / REQUEST evidence
  │   └─ YES ↓
  │
  ├─ Is [next criterion]?
  │   ├─ NO → REFUSE / ESCALATE
  │   └─ YES ↓
  │
  └─ APPROVE
      Outcome: [what happens]
      Conditions: [any conditions on approval]
  ```

  STATE TRANSITIONS — markdown table:
  | Current State | Trigger | Next State | Action | Auto? |
  |---|---|---|---|---|

  EVIDENCE REQUIREMENTS — markdown table:
  | Evidence | Required? | Source | Verification | Deadline |
  |---|---|---|---|---|

  CORRESPONDENCE TEMPLATES — markdown with {{ variables }}, formal gov tone:
  ## [Stage name]
  Dear {{ applicant_name }},
  ...
  Include: acknowledgement, evidence request, approval, refusal templates.

  RISK SCORING — specific numeric rules:
  ## Risk Score Calculation
  - SLA ≤ 0 days remaining: +40
  - SLA ≤ 7 days: +25
  ...

  Rules:
  - Decision tree MUST use the ASCII box-drawing format shown above
  - Be specific to THIS process, not generic
  - Correspondence must sound like real government letters — formal, clear, plain English
  - Risk scoring must use specific numbers that add up
  - Return ONLY valid JSON
PROMPT

# ══════════════════════════════════════════════════════════════
# MAIN PIPELINE
# ══════════════════════════════════════════════════════════════

url = ARGV[0]

puts
puts C.bold("  ╔══════════════════════════════════════════════════════╗")
puts C.bold("  ║   AI CASE TYPE BUILDER — Interactive Pipeline       ║")
puts C.bold("  ╚══════════════════════════════════════════════════════╝")
puts

# ── Step 0: Get URL ──────────────────────────────────────────

unless url
  step_header(0, "INPUT")
  puts "  Enter a URL to a government process page, or press Enter for the default."
  puts C.dim("  Default: Swansea black bag exemption")
  url = prompt_user("URL:", default: "https://www.swansea.gov.uk/article/5075/Apply-for-a-black-bag-limit-exemption")
end

# ── Step 1: Scrape ───────────────────────────────────────────

step_header(1, "SCRAPE — Fetching the page")

result = scrape_page(url)
puts "  #{C.green("✅")} Scraped: #{C.bold(result[:title])}"
puts "  #{result[:text].length} chars extracted"
puts "  #{result[:links].length} links found on page"
puts
puts C.dim("  --- Content preview (first 300 chars) ---")
puts C.dim("  " + result[:text][0, 300].gsub("\n", "\n  "))
puts C.dim("  ...")

all_content = "## Main Page: #{result[:title]}\n\n#{result[:text]}"

# ── Step 1b: Follow relevant links ──────────────────────────

if result[:links].any?
  wait_for_enter

  step_header("1b", "LINK DISCOVERY — Finding related pages")

  puts "  Asking LLM which links are worth following..."
  links_text = result[:links].map { |l| "- #{l[:text]}: #{l[:url]}" }.join("\n")

  link_response = llm_call(
    LINK_RELEVANCE_PROMPT,
    "Main page content:\n#{result[:text][0, 2000]}\n\nLinks found:\n#{links_text}"
  )

  relevant_links = SandboxHelpers.parse_llm_json(link_response)
  puts
  if relevant_links.empty?
    puts "  No additional pages needed — main page has enough info."
  else
    puts "  #{C.bold("Found #{relevant_links.length} relevant links:")}"
    relevant_links.each_with_index do |link, i|
      puts "    #{i + 1}. #{C.cyan(link['url'])}"
      puts "       #{C.dim(link['reason'])}"
    end

    puts
    choice = prompt_user(
      "Follow these links to gather more info?",
      options: [ "Yes — scrape all #{relevant_links.length} links", "Let me pick which ones", "No — skip, use main page only" ],
      default: 1
    )

    links_to_follow = case choice
    when /Yes/
      relevant_links
    when /pick/
      relevant_links.select.with_index do |link, i|
        answer = prompt_user("Follow '#{link['url'].split('/').last(2).join('/')}'?", options: [ "Yes", "No" ], default: 1)
        answer == "Yes"
      end
    else
      []
    end

    links_to_follow.each do |link|
      begin
        puts "  #{C.yellow("⏳")} Scraping: #{link['url']}"
        sub_result = scrape_page(link["url"])
        all_content += "\n\n## Linked Page: #{sub_result[:title]}\n\n#{sub_result[:text]}"
        puts "  #{C.green("✅")} Got #{sub_result[:text].length} chars"
      rescue => e
        puts "  #{C.red("✗")} Failed: #{e.message}"
      end
    end

    puts
    puts "  #{C.green("✅")} Total content gathered: #{all_content.length} chars from #{1 + links_to_follow.length} pages"
  end
end

# Trim to LLM-friendly size
all_content = all_content[0, 12000] if all_content.length > 12000

wait_for_enter

# ── Step 2: Analysis ─────────────────────────────────────────

step_header(2, "ANALYSIS — Understanding the process")

puts "  Sending #{all_content.length} chars to GPT-4o for analysis..."
analysis_text = llm_call(ANALYSIS_PROMPT, "Analyse this government process:\n\n#{all_content}", max_tokens: 3000)
analysis = SandboxHelpers.parse_llm_json(analysis_text)

puts
puts "  #{C.green("✅")} Analysis complete"
divider
puts "  #{C.bold("Name:")}       #{analysis['name']}"
puts "  #{C.bold("Applicant:")}  #{analysis['applicant_type']}"
puts "  #{C.bold("Caseworker:")} #{analysis['caseworker_type']}"
puts "  #{C.bold("SLA:")}        #{analysis['typical_timeline_days']} days"
puts "  #{C.bold("Evidence:")}   #{analysis['evidence_requirements']&.length || 0} items"
puts "  #{C.bold("Criteria:")}   #{analysis['eligibility_criteria']&.length || 0} checks"
puts "  #{C.bold("Outcomes:")}   #{analysis['possible_outcomes']&.join(', ')}"
divider

# Show evidence
if analysis["evidence_requirements"]&.any?
  puts
  puts "  #{C.bold("Evidence Requirements:")}"
  analysis["evidence_requirements"].each do |ev|
    req = ev["required"]
    icon = req == "mandatory" ? "🔴" : (req == "conditional" ? "🟡" : "⚪")
    puts "    #{icon} #{ev['name']} (#{req}) — #{ev['source']}"
    puts "       #{C.dim(ev['condition'])}" if ev["condition"]
  end
end

# Show decision logic
if analysis["decision_logic"]&.any?
  puts
  puts "  #{C.bold("Decision Logic:")}"
  analysis["decision_logic"].each do |step|
    puts "    #{step['step']}. #{step['check']}"
    puts "       YES → #{step['yes']} | NO → #{step['no']}"
  end
end

# Show confidence
puts
puts "  #{C.bold("Confidence Scores:")}"
analysis["confidence_scores"]&.each do |key, score|
  bar = "█" * (score * 20).round + "░" * (20 - (score * 20).round)
  flag = score < 0.7 ? " ⚠️" : " ✓"
  puts "    #{key.ljust(15)} #{bar} #{(score * 100).round}%#{flag}"
end

wait_for_enter

# ── Step 2b: Clarifying Questions (enrichment after each answer) ──

answers = {}
question_num = 0

questions = analysis["clarifying_questions"] || []

if questions.any?
  step_header("2b", "CLARIFYING QUESTIONS — #{questions.length} initial questions")

  puts "  The analysis has some low-confidence areas. Let's clarify."
  puts "  After each answer, the analysis is re-enriched — new questions may"
  puts "  appear and confidence scores will update in real time."
  puts

  skip_all = false

  while questions.any? && !skip_all
    q = questions.shift
    question_num += 1

    divider("·")
    puts
    remaining = questions.length
    puts "  #{C.bold("Q#{question_num}:")} #{q['question']}  #{C.dim("(#{remaining} remaining)")}"
    puts "  #{C.dim("Element: #{q['element']} | Why: #{q['why']}")}"
    if q["impact"]
      puts "  #{C.dim("Impact: #{q['impact']}")}"
    end
    puts

    options = (q["options"] || []) + [ "Skip this question", "Skip all remaining" ]
    selected = prompt_user("Your answer:", options: options, default: 1)

    case selected
    when "Skip all remaining"
      skip_all = true
      puts C.yellow("  Skipping remaining questions — LLM will use best judgement.")
    when "Skip this question"
      puts C.dim("  Skipped.")
    else
      answers[q["element"]] ||= []
      answers[q["element"]] << { question: q["question"], answer: selected }

      # ── Enrich immediately after this answer ──
      puts
      puts "  #{C.yellow("⏳")} Re-enriching analysis with your answer..."

      enrichment_input = {
        original_analysis: analysis,
        answers: answers
      }

      enriched_text = llm_call(
        ENRICHMENT_PROMPT,
        "Update this analysis with the admin's answers:\n\n#{JSON.pretty_generate(enrichment_input)}",
        max_tokens: 3000
      )
      analysis = SandboxHelpers.parse_llm_json(enriched_text)

      puts "  #{C.green("✅")} Analysis updated"

      # Show updated confidence
      puts
      puts "  #{C.bold("Confidence after Q#{question_num}:")}"
      analysis["confidence_scores"]&.each do |key, score|
        bar = "█" * (score * 20).round + "░" * (20 - (score * 20).round)
        flag = score < 0.7 ? " ⚠️" : " ✓"
        puts "    #{key.ljust(15)} #{bar} #{(score * 100).round}%#{flag}"
      end

      # Pull fresh questions from the updated analysis (LLM may have added new ones)
      new_questions = analysis["clarifying_questions"] || []
      if new_questions.any?
        # Deduplicate — only add questions we haven't already asked
        asked = answers.values.flatten.map { |a| a[:question] }
        fresh = new_questions.reject { |nq| asked.include?(nq["question"]) }
        if fresh.length != questions.length || fresh.map { |f| f["question"] } != questions.map { |q2| q2["question"] }
          questions = fresh
          if questions.any?
            puts
            puts "  #{C.cyan("ℹ")}  #{questions.length} question(s) remaining after re-analysis"
          end
        end
      else
        questions = []
        puts
        puts "  #{C.green("✅")} All confidence scores are now high — no more questions needed!"
      end
    end
    puts
  end

  if answers.any?
    puts
    divider
    puts "  #{C.bold("Q&A Summary:")} #{answers.values.flatten.length} answers across #{question_num} questions"
    divider
  end
else
  puts
  puts "  #{C.green("✅")} No clarifying questions needed — analysis confidence is high."
end

wait_for_enter

# ── Step 3: Generate ─────────────────────────────────────────

step_header(3, "GENERATE — Building case type configuration")

puts "  Sending enriched analysis to GPT-4o for config generation..."
gen_text = llm_call(
  GENERATION_PROMPT,
  "Generate a complete case type configuration:\n\n#{JSON.pretty_generate(analysis)}",
  max_tokens: 4000
)
config = SandboxHelpers.parse_llm_json(gen_text)

puts
puts "  #{C.green("✅")} Configuration generated"
divider
puts "  #{C.bold("Name:")} #{config['name']}"
puts "  #{C.bold("Slug:")} #{config['slug']}"
puts "  #{C.bold("Org:")}  #{config['organisation']}"
puts "  #{C.bold("SLA:")}  #{config['default_sla_days']} days"
divider

# Display each section
sections = {
  "decision_tree_md" => "DECISION TREE",
  "state_transitions_md" => "STATE TRANSITIONS",
  "evidence_requirements_md" => "EVIDENCE REQUIREMENTS",
  "correspondence_templates_md" => "CORRESPONDENCE TEMPLATES",
  "risk_scoring_md" => "RISK SCORING"
}

sections.each do |key, title|
  puts
  divider
  puts "  #{C.bold("📄 #{title}")}"
  divider
  content = config[key] || "(empty)"
  content.each_line { |line| puts "  #{line}" }

  choice = prompt_user(
    "Accept this section?",
    options: [ "Accept", "Regenerate (re-run LLM for this section)", "Edit manually later" ],
    default: 1
  )

  if choice =~ /Regenerate/
    puts "  #{C.yellow("⏳")} Regenerating #{title}..."
    regen_prompt = "Regenerate ONLY the #{key} section for this case type. Return ONLY the markdown content for this section, no JSON wrapper.\n\nFull analysis:\n#{JSON.pretty_generate(analysis)}\n\nCurrent version:\n#{config[key]}\n\nMake it more detailed and specific."
    new_content = llm_call("You are an expert government service designer.", regen_prompt, max_tokens: 2000)
    config[key] = new_content.gsub(/\A\s*```(?:markdown)?\s*\n?/, "").gsub(/\n?\s*```\s*\z/, "").strip
    puts
    config[key].each_line { |line| puts "  #{C.green(line)}" }
  end
end

# ── Step 4: Review & Save ────────────────────────────────────

step_header(4, "REVIEW & SAVE")

puts "  #{C.bold("Final Configuration Summary:")}"
puts
puts "  Name:         #{config['name']}"
puts "  Slug:         #{config['slug']}"
puts "  Organisation: #{config['organisation']}"
puts "  SLA:          #{config['default_sla_days']} days"
puts "  Sections:     #{sections.count { |k, _| config[k]&.length.to_i > 0 }}/5 generated"
puts

choice = prompt_user(
  "What would you like to do?",
  options: [ "Save as Draft", "Publish", "Discard" ],
  default: 1
)

FileUtils.mkdir_p(File.join(__dir__, "output"))
timestamp = Time.now.strftime("%Y%m%d_%H%M%S")

# Save everything
output = {
  config: config,
  analysis: analysis,
  answers: answers,
  source_url: url,
  pages_scraped: all_content.scan(/^## (?:Main|Linked) Page:/).length,
  generated_at: Time.now.iso8601,
  status: choice.downcase.gsub(" ", "_")
}

output_path = File.join(__dir__, "output", "pipeline_#{timestamp}.json")
File.write(output_path, JSON.pretty_generate(output))

puts
puts "  #{C.green("✅")} Saved to: #{output_path}"

# Token summary
puts
divider("═")
puts "  #{C.bold("SESSION SUMMARY")}"
divider("═")
puts "  Pages scraped:      #{output[:pages_scraped]}"
puts "  Questions answered:  #{answers.values.flatten.length}"
puts "  LLM calls:          #{TOTAL_TOKENS[:prompt] > 0 ? 'multiple' : '0'}"
puts "  Total prompt tokens: #{TOTAL_TOKENS[:prompt]}"
puts "  Total comp. tokens:  #{TOTAL_TOKENS[:completion]}"
puts "  Total tokens:        #{TOTAL_TOKENS[:prompt] + TOTAL_TOKENS[:completion]}"
puts
puts C.green("  Done! This output can be loaded directly into the Rails app.")
puts
