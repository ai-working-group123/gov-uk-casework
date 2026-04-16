#!/usr/bin/env ruby
# Shared helpers for all sandbox scripts.

require "json"

module SandboxHelpers
  # Strip markdown code fences from LLM responses that wrap JSON
  def self.parse_llm_json(text)
    cleaned = text
      .gsub(/\A\s*```(?:json)?\s*\n?/, "")  # opening fence
      .gsub(/\n?\s*```\s*\z/, "")            # closing fence
      .strip
    JSON.parse(cleaned)
  end
end
