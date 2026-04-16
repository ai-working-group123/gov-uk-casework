#!/usr/bin/env ruby
# Test the analysis prompt (Step 2) — send a process description, get structured JSON back.
# Usage:
#   ruby test_analysis_prompt.rb                    # uses built-in sample text
#   ruby test_analysis_prompt.rb path/to/text.txt   # uses file content

require "bundler/setup"
require "dotenv"
require "openai"
require "json"
require_relative "helpers"

Dotenv.load(File.join(__dir__, "..", ".env"))

ANALYSIS_PROMPT = <<~PROMPT
  You are an expert government process analyst. Given a description of a government or public sector process, analyse it and return a JSON object with these keys:

  {
    "name": "Short case type name",
    "description": "One-sentence description of the process",
    "applicant_type": "Who applies (e.g. Resident, Employer, Vehicle keeper)",
    "caseworker_type": "Who decides (e.g. Planning officer, Waste officer)",
    "evidence_requirements": [
      { "name": "Document name", "required": true/false, "source": "Who provides it", "notes": "Any conditions" }
    ],
    "eligibility_criteria": [
      { "criterion": "Description of check", "type": "pass_fail | subjective | conditional" }
    ],
    "possible_outcomes": ["Approved", "Refused", ...],
    "typical_timeline_days": 14,
    "communication_steps": [
      { "stage": "When", "channel": "email/letter/portal", "content": "What is communicated" }
    ],
    "confidence_scores": {
      "name": 0.95,
      "description": 0.9,
      "evidence": 0.5,
      "eligibility": 0.7,
      "outcomes": 0.8,
      "timeline": 0.6,
      "communication": 0.4
    },
    "clarifying_questions": [
      {
        "question": "The specific question",
        "element": "Which element this clarifies (evidence, eligibility, etc)",
        "options": ["Option A", "Option B", "Option C"],
        "why": "Why this matters for the case type config"
      }
    ]
  }

  Rules:
  - Only include clarifying_questions for elements where confidence < 0.7
  - Each question should have 2-4 suggested options
  - Be specific — don't ask vague questions
  - Confidence scores should reflect how much you can infer vs what's ambiguous
  - Return ONLY valid JSON, no markdown fences, no explanation
PROMPT

SAMPLE_TEXT = <<~TEXT
  Black bag limit exemption — Swansea Council

  If you recycle all accepted kerbside materials, you may apply for an exemption
  to the 3 black bag limit. This is for residents who genuinely have
  non-recyclable waste such as pet litter, nappies, or medical waste.

  To apply, fill in the online form with your address, number of people in your
  household, and a description of why you need more than 3 bags.

  A waste enforcement officer will review your application. They may arrange a
  home visit to verify your recycling and waste situation. If approved, you'll
  receive a letter confirming your exemption, which lasts for 12 months.
  After that, you need to reapply.

  You can expect a decision within 14 working days. If refused, you can appeal
  by contacting the waste team.
TEXT

# Load input
input_text = if ARGV[0] && File.exist?(ARGV[0])
               File.read(ARGV[0])
else
               puts "Using built-in sample text (Black Bag Exemption)"
               puts "Tip: pass a file path as argument to test with different content\n\n"
               SAMPLE_TEXT
end

client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

puts "Sending analysis prompt..."
puts "Input length: #{input_text.length} chars"
puts "-" * 60

start_time = Time.now

response = client.chat(
  parameters: {
    model: "gpt-4o",
    messages: [
      { role: "system", content: ANALYSIS_PROMPT },
      { role: "user", content: "Analyse this government process:\n\n#{input_text}" }
    ],
    max_completion_tokens: 2000,
    temperature: 0.3
  }
)

elapsed = (Time.now - start_time).round(2)
content = response.dig("choices", 0, "message", "content")
usage = response["usage"]

if content
  puts "\n✅ Response received in #{elapsed}s\n\n"

  # Try to parse as JSON
  begin
    parsed = SandboxHelpers.parse_llm_json(content)
    puts JSON.pretty_generate(parsed)

    # Summary
    puts "\n" + "=" * 60
    puts "SUMMARY"
    puts "=" * 60
    puts "Name:       #{parsed['name']}"
    puts "Applicant:  #{parsed['applicant_type']}"
    puts "Caseworker: #{parsed['caseworker_type']}"
    puts "SLA:        #{parsed['typical_timeline_days']} days"
    puts "Evidence:   #{parsed['evidence_requirements']&.length || 0} items"
    puts "Criteria:   #{parsed['eligibility_criteria']&.length || 0} checks"
    puts "Questions:  #{parsed['clarifying_questions']&.length || 0} to ask"

    puts "\nConfidence scores:"
    parsed["confidence_scores"]&.each do |key, score|
      bar = "█" * (score * 20).round + "░" * (20 - (score * 20).round)
      flag = score < 0.7 ? " ⚠️" : ""
      puts "  #{key.ljust(15)} #{bar} #{(score * 100).round}%#{flag}"
    end

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
