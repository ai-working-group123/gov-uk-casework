# E3 Prompt Sandbox

Standalone scripts for testing OpenAI calls and tuning prompts **before** wiring into Rails.

## Setup

```bash
cd sandbox
bundle install
```

## Scripts

| Script | Purpose |
|--------|---------|
| `test_connection.rb` | Smoke test — confirms API key works |
| `test_analysis_prompt.rb` | Step 2 — process analysis from text/URL |
| `test_generation_prompt.rb` | Step 3 — generate case type config from analysis |
| `test_scrape_and_analyse.rb` | Full pipeline — scrape URL → analyse → generate |

## Usage

```bash
ruby test_connection.rb
ruby test_analysis_prompt.rb
ruby test_generation_prompt.rb
ruby test_scrape_and_analyse.rb "https://www.swansea.gov.uk/article/5075/Apply-for-a-black-bag-limit-exemption"
```

All scripts load the API key from `../.env`.
