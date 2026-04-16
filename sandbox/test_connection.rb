#!/usr/bin/env ruby
# Smoke test: confirms OpenAI API key works and returns a response.

require "bundler/setup"
require "dotenv"
require "openai"

Dotenv.load(File.join(__dir__, "..", ".env"))

client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

puts "Testing OpenAI connection..."
puts "Model: gpt-4o"
puts "-" * 50

response = client.chat(
  parameters: {
    model: "gpt-4o",
    messages: [
      { role: "system", content: "You are a government process analyst." },
      { role: "user", content: "Describe the steps in processing a UK visa application in 3 bullet points." }
    ],
    max_tokens: 300
  }
)

content = response.dig("choices", 0, "message", "content")
usage = response["usage"]

if content
  puts "\n✅ SUCCESS\n\n"
  puts content
  puts "\n----- Usage -----"
  puts "Prompt tokens:     #{usage['prompt_tokens']}"
  puts "Completion tokens: #{usage['completion_tokens']}"
  puts "Total tokens:      #{usage['total_tokens']}"
else
  puts "\n❌ FAILED"
  puts response.inspect
  exit 1
end
