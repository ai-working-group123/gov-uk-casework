#!/usr/bin/env ruby
# Test the generation prompt (Step 3) — takes an analysis JSON, produces full case type config.
# Usage:
#   ruby test_generation_prompt.rb                         # uses built-in sample analysis
#   ruby test_generation_prompt.rb path/to/analysis.json   # uses saved analysis output

require "bundler/setup"
require "dotenv"
require "openai"
require "json"
require_relative "helpers"

Dotenv.load(File.join(__dir__, "..", ".env"))

GENERATION_PROMPT = <<~PROMPT
  You are an expert government service designer. Given a structured analysis of a government process, generate a complete case type configuration.

  Return a JSON object with these keys:

  {
    "name": "Case type name",
    "slug": "snake_case_slug",
    "description": "One-sentence description",
    "organisation": "Organisation name",
    "default_sla_days": 14,
    "decision_tree_md": "markdown decision tree (see format below)",
    "state_transitions_md": "markdown table of state transitions",
    "evidence_requirements_md": "markdown table of evidence requirements",
    "correspondence_templates_md": "markdown correspondence templates",
    "risk_scoring_md": "markdown risk scoring rules"
  }

  FORMAT RULES:

  **decision_tree_md** — Use this exact format:
  ```
  START
  │
  ├─ [Check description]?
  │   ├─ NO → [outcome or next step]
  │   └─ YES ↓
  │
  ├─ [Next check]?
  │   ├─ NO → REFUSE (reason)
  │   └─ YES ↓
  │
  └─ APPROVE
  ```

  **state_transitions_md** — Markdown table:
  ```
  | Current State | Trigger | Next State | Action |
  |---|---|---|---|
  | submitted | Auto-assign | assigned | Notify caseworker |
  ```

  **evidence_requirements_md** — Markdown table:
  ```
  | Evidence | Required? | Source | Verification Method |
  |---|---|---|---|
  | Proof of address | Mandatory | Applicant | Cross-check with council records |
  ```

  **correspondence_templates_md** — Markdown templates with {{ variables }}:
  ```
  ## Application Received
  Dear {{ applicant_name }},
  We have received your application for {{ case_type }}...

  ## Decision: Approved
  ...
  ```

  **risk_scoring_md** — Markdown rules:
  ```
  ## Risk Score Calculation
  - SLA deadline ≤ 0 days: +40
  - SLA deadline ≤ 7 days: +25
  - Evidence < 50% received: +20
  - No activity > 14 days: +10
  ```

  Rules:
  - Make decision trees specific to the process, not generic
  - State transitions should cover all realistic paths including edge cases
  - Evidence table should distinguish mandatory vs conditional
  - Templates should feel like real government correspondence — formal, clear, plain English
  - Risk scoring should be tailored to this specific case type
  - Return ONLY valid JSON, no markdown fences wrapping the outer JSON
PROMPT

SAMPLE_ANALYSIS = {
  "name" => "Black Bag Limit Exemption",
  "description" => "Residents apply for exemption to the 3 black bag limit for non-recyclable waste",
  "applicant_type" => "Resident",
  "caseworker_type" => "Waste enforcement officer",
  "evidence_requirements" => [
    { "name" => "Online application form", "required" => true, "source" => "Applicant", "notes" => "Address, household size, reason" },
    { "name" => "Description of non-recyclable waste", "required" => true, "source" => "Applicant", "notes" => "Type: pet litter, nappies, medical" },
    { "name" => "Home visit report", "required" => false, "source" => "Officer", "notes" => "At officer discretion" }
  ],
  "eligibility_criteria" => [
    { "criterion" => "Resident recycles all accepted kerbside materials", "type" => "pass_fail" },
    { "criterion" => "Waste is genuinely non-recyclable", "type" => "subjective" },
    { "criterion" => "Household circumstances justify exemption", "type" => "subjective" }
  ],
  "possible_outcomes" => ["Approved (12-month exemption)", "Refused", "Approved with conditions"],
  "typical_timeline_days" => 14,
  "communication_steps" => [
    { "stage" => "Receipt", "channel" => "email", "content" => "Application received confirmation" },
    { "stage" => "Visit", "channel" => "letter", "content" => "Home visit appointment (if needed)" },
    { "stage" => "Decision", "channel" => "letter", "content" => "Approval or refusal with reasons" }
  ]
}

# Load input
analysis = if ARGV[0] && File.exist?(ARGV[0])
              JSON.parse(File.read(ARGV[0]))
            else
              puts "Using built-in sample analysis (Black Bag Exemption)"
              puts "Tip: pass a JSON file as argument to test with different analysis\n\n"
              SAMPLE_ANALYSIS
            end

client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

puts "Sending generation prompt..."
puts "Analysis: #{analysis['name']}"
puts "-" * 60

start_time = Time.now

response = client.chat(
  parameters: {
    model: "gpt-4o",
    messages: [
      { role: "system", content: GENERATION_PROMPT },
      { role: "user", content: "Generate a complete case type configuration from this analysis:\n\n#{JSON.pretty_generate(analysis)}" }
    ],
    max_tokens: 4000,
    temperature: 0.3
  }
)

elapsed = (Time.now - start_time).round(2)
content = response.dig("choices", 0, "message", "content")
usage = response["usage"]

if content
  puts "\n✅ Response received in #{elapsed}s\n\n"

  begin
    parsed = SandboxHelpers.parse_llm_json(content)

    # Show each section
    puts "=" * 60
    puts "NAME: #{parsed['name']}"
    puts "SLUG: #{parsed['slug']}"
    puts "ORG:  #{parsed['organisation']}"
    puts "SLA:  #{parsed['default_sla_days']} days"
    puts "=" * 60

    %w[decision_tree_md state_transitions_md evidence_requirements_md correspondence_templates_md risk_scoring_md].each do |section|
      puts "\n#{'─' * 60}"
      puts "📄 #{section.gsub('_md', '').gsub('_', ' ').upcase}"
      puts "─" * 60
      puts parsed[section] || "(empty)"
    end

    # Save full output for reuse
    output_path = File.join(__dir__, "output", "generation_#{Time.now.strftime('%H%M%S')}.json")
    FileUtils.mkdir_p(File.dirname(output_path))
    File.write(output_path, JSON.pretty_generate(parsed))
    puts "\n💾 Full output saved to: #{output_path}"

  rescue JSON::ParserError => e
    puts "⚠️  Response is not valid JSON — raw output:"
    puts content
  end

  puts "\n----- Usage -----"
  puts "Prompt tokens:     #{usage['prompt_tokens']}"
  puts "Completion tokens: #{usage['completion_tokens']}"
  puts "Total tokens:      #{usage['total_tokens']}"
  puts "Time:              #{elapsed}s"
else
  puts "\n❌ FAILED"
  puts response.inspect
  exit 1
end
