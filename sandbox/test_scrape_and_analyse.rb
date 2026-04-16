#!/usr/bin/env ruby
# Full pipeline test: scrape a URL → analyse → generate.
# Usage:
#   ruby test_scrape_and_analyse.rb "https://www.swansea.gov.uk/article/5075/Apply-for-a-black-bag-limit-exemption"
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

def scrape(url)
  puts "🌐 Scraping: #{url}"
  uri = URI.parse(url)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == "https"
  http.open_timeout = 10
  http.read_timeout = 10

  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "GovUK-Casework-Builder/1.0 (hackathon prototype)"

  response = http.request(request)

  unless response.is_a?(Net::HTTPSuccess)
    raise "HTTP #{response.code}: #{response.message}"
  end

  doc = Nokogiri::HTML(response.body)

  # Remove noise
  doc.css("nav, footer, header, script, style, noscript, .cookie-banner, #cookie-banner, .govuk-breadcrumbs").each(&:remove)

  # Find main content
  main = doc.at_css("main") || doc.at_css("[role='main']") || doc.at_css("article") || doc.at_css("body")

  text = main.text
    .gsub(/\s+/, " ")          # collapse whitespace
    .gsub(/\n{3,}/, "\n\n")   # max 2 newlines
    .strip

  # Limit to 5000 chars
  text = text[0, 5000] if text.length > 5000

  puts "📄 Scraped #{text.length} chars"
  text
end

# ── Prompts ──────────────────────────────────────────────────

ANALYSIS_PROMPT = <<~PROMPT
  You are an expert government process analyst. Given a description of a government or public sector process, analyse it and return a JSON object with these keys:

  {
    "name": "Short case type name",
    "description": "One-sentence description",
    "applicant_type": "Who applies",
    "caseworker_type": "Who decides",
    "evidence_requirements": [
      { "name": "Document name", "required": true/false, "source": "Who provides it", "notes": "Conditions" }
    ],
    "eligibility_criteria": [
      { "criterion": "Description of check", "type": "pass_fail | subjective | conditional" }
    ],
    "possible_outcomes": ["Approved", "Refused"],
    "typical_timeline_days": 14,
    "communication_steps": [
      { "stage": "When", "channel": "email/letter/portal", "content": "What" }
    ],
    "confidence_scores": {
      "name": 0.9, "evidence": 0.5, "eligibility": 0.7, "timeline": 0.6
    },
    "clarifying_questions": [
      { "question": "...", "element": "evidence", "options": ["A", "B", "C"], "why": "..." }
    ]
  }

  Only include clarifying_questions for elements where confidence < 0.7.
  Return ONLY valid JSON.
PROMPT

GENERATION_PROMPT = <<~PROMPT
  You are an expert government service designer. Given a structured analysis, generate a complete case type configuration as JSON:

  {
    "name": "Case type name",
    "slug": "snake_case_slug",
    "description": "One-sentence description",
    "organisation": "Organisation name",
    "default_sla_days": 14,
    "decision_tree_md": "markdown decision tree using START/branches/APPROVE/REFUSE format",
    "state_transitions_md": "markdown table: Current State | Trigger | Next State | Action",
    "evidence_requirements_md": "markdown table: Evidence | Required? | Source | Verification Method",
    "correspondence_templates_md": "markdown templates with {{ variables }}",
    "risk_scoring_md": "markdown risk scoring rules"
  }

  Make it specific to the process. Use plain English. Return ONLY valid JSON.
PROMPT

# ── Main ─────────────────────────────────────────────────────

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
    model: "gpt-4o",
    messages: [
      { role: "system", content: ANALYSIS_PROMPT },
      { role: "user", content: "Analyse this government process:\n\n#{scraped_text}" }
    ],
    max_completion_tokens: 2000,
    temperature: 0.3
  }
)

analysis_text = analysis_response.dig("choices", 0, "message", "content")
analysis = SandboxHelpers.parse_llm_json(analysis_text)
elapsed_analysis = (Time.now - start).round(2)

puts "✅ Analysis complete in #{elapsed_analysis}s"
puts "   Name: #{analysis['name']}"
puts "   Questions: #{analysis['clarifying_questions']&.length || 0}"

# Show questions if any
if analysis["clarifying_questions"]&.any?
  puts "\n❓ Clarifying Questions:"
  analysis["clarifying_questions"].each_with_index do |q, i|
    puts "   #{i + 1}. #{q['question']}"
    q["options"]&.each { |opt| puts "      • #{opt}" }
  end
end

# Step 3: Generate
puts "\n⚙️  Step 3: Generating case type config..."
start = Time.now

gen_response = client.chat(
  parameters: {
    model: "gpt-4o",
    messages: [
      { role: "system", content: GENERATION_PROMPT },
      { role: "user", content: "Generate config from this analysis:\n\n#{JSON.pretty_generate(analysis)}" }
    ],
    max_completion_tokens: 4000,
    temperature: 0.3
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
puts "SLA:  #{config['default_sla_days']} days"

%w[decision_tree_md state_transitions_md evidence_requirements_md correspondence_templates_md risk_scoring_md].each do |section|
  puts "\n#{'─' * 60}"
  puts "📄 #{section.gsub('_md', '').gsub('_', ' ').upcase}"
  puts "─" * 60
  puts config[section] || "(empty)"
end

# Save outputs
FileUtils.mkdir_p(File.join(__dir__, "output"))
timestamp = Time.now.strftime("%H%M%S")
File.write(File.join(__dir__, "output", "analysis_#{timestamp}.json"), JSON.pretty_generate(analysis))
File.write(File.join(__dir__, "output", "config_#{timestamp}.json"), JSON.pretty_generate(config))
puts "\n💾 Outputs saved to sandbox/output/"

# Token summary
a_usage = analysis_response["usage"]
g_usage = gen_response["usage"]
puts "\n----- Total Usage -----"
puts "Analysis:   #{a_usage['total_tokens']} tokens (#{elapsed_analysis}s)"
puts "Generation: #{g_usage['total_tokens']} tokens (#{elapsed_gen}s)"
puts "Total:      #{a_usage['total_tokens'] + g_usage['total_tokens']} tokens"
