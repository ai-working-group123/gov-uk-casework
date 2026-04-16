# E3a — Backend: Services, Models & LLM Pipeline

## Your Role

You build the **engine** — the services that scrape, analyse, and generate case type configs via LLM. E3b builds the UI that calls your services. You work in parallel and integrate at merge points.

**Your files — nobody else touches these:**

| Layer          | Files                                                                                              |
| -------------- | -------------------------------------------------------------------------------------------------- |
| **Migrations** | `create_case_type_configs`, `create_case_type_generation_logs`                                     |
| **Models**     | `app/models/case_type_config.rb`, `app/models/case_type_generation_log.rb`                         |
| **Services**   | `app/services/llm_client.rb`, `app/services/url_scraper.rb`, `app/services/case_type_generator.rb` |

---

## Interface Contract (E3b depends on this)

E3b will call your services via these exact method signatures. **Agree this before splitting off.**

```ruby
# LlmClient
LlmClient.available?                    # => true/false
LlmClient.model_name                    # => "gpt-4o"
LlmClient.new.call(system_prompt:, user_prompt:, max_completion_tokens: 4000) # => String

# UrlScraper
UrlScraper.new.call(url)                # => String (cleaned text, max 5000 chars)
                                        # raises UrlScraper::Error on failure

# CaseTypeGenerator
gen = CaseTypeGenerator.new(case_type_config)
gen.scrape_and_analyse!                 # => Hash (analysis with confidence scores + questions)
gen.generate_config!(answers: {})       # => CaseTypeConfig (updated with generated markdown)
```

### `scrape_and_analyse!` return shape:

```ruby
{
  name: "Black Bag Limit Exemption",
  description: "...",
  applicant_type: "Resident",
  caseworker_type: "Waste officer",
  evidence_requirements: [...],
  eligibility_criteria: [...],
  possible_outcomes: [...],
  typical_timeline: "14 days",
  communication_steps: [...],
  confidence_scores: { name: 0.9, evidence: 0.5, ... },
  clarifying_questions: [
    { question: "...", options: ["A", "B", "C"], element: "evidence" }
  ]
}
```

### `generate_config!` updates these CaseTypeConfig columns:

- `decision_tree_md`
- `state_transitions_md`
- `evidence_requirements_md`
- `correspondence_templates_md`
- `risk_scoring_md`
- `name`, `slug`, `description`, `default_sla_days`

---

## Pre-Build (08:30–09:55)

| #   | Task                                                                 | Status | Notes                                          |
| --- | -------------------------------------------------------------------- | ------ | ---------------------------------------------- |
| 1   | Add gem: `ruby-openai` (or `anthropic`) to Gemfile, `bundle install` | ⬜     | Coordinate with E3b who adds `redcarpet`       |
| 2   | Confirm LLM API key works — test from `irb`/console                  | ⬜     | `OPENAI_API_KEY` or `ANTHROPIC_API_KEY` in ENV |
| 3   | Create migration `create_case_type_configs`                          | ⬜     | Schema below                                   |
| 4   | Create migration `create_case_type_generation_logs`                  | ⬜     | Schema below                                   |
| 5   | Create `CaseTypeConfig` model with enums, validations                | ⬜     |                                                |
| 6   | Create `CaseTypeGenerationLog` model                                 | ⬜     |                                                |
| 7   | Create `app/services/llm_client.rb`                                  | ⬜     |                                                |
| 8   | Create `app/services/url_scraper.rb`                                 | ⬜     |                                                |
| 9   | `rails db:migrate` — verify models in console                        | ⬜     |                                                |

**Done when:** `LlmClient.new.call(...)` returns text. Models save to DB. `UrlScraper` fetches a page.

---

## Phase 1 (09:55–11:00) — Analysis Pipeline

| #   | Task                                                    | Status | Notes                                                         |
| --- | ------------------------------------------------------- | ------ | ------------------------------------------------------------- |
| 10  | Create `app/services/case_type_generator.rb`            | ⬜     |                                                               |
| 11  | Implement `scrape_and_analyse!` — Steps 1+2 of pipeline | ⬜     | Scrape URLs → send to LLM → parse JSON → return analysis hash |
| 12  | Write + test the Analysis Prompt (Step 2)               | ⬜     | Get JSON back reliably, tune prompt                           |
| 13  | Implement clarifying questions extraction from analysis | ⬜     | Filter elements with confidence < 0.6                         |
| 14  | Log each step to `CaseTypeGenerationLog`                | ⬜     | input_text, output_text, model_used, tokens, confidence       |

**🔗 MERGE POINT 1 (11:00):** Push services. E3b wires their controller/views to your real services.

**Done when:** `CaseTypeGenerator.new(config).scrape_and_analyse!` returns a valid analysis hash with questions.

---

## Phase 2 (11:40–12:30) — Generation Pipeline

| #   | Task                                                      | Status | Notes                                                                 |
| --- | --------------------------------------------------------- | ------ | --------------------------------------------------------------------- |
| 15  | Implement `generate_config!(answers:)` — Step 3           | ⬜     | Merge answers into analysis → send generation prompt → parse response |
| 16  | Write + test the Generation Prompt (Step 3)               | ⬜     | Must return valid JSON with all 5 markdown sections                   |
| 17  | Handle answer merging — enrich analysis before generation | ⬜     |                                                                       |
| 18  | Add `regenerate_section!(section_name)` method            | ⬜     | Re-runs LLM for one section only                                      |
| 19  | Test end-to-end in console: scrape → analyse → generate   | ⬜     |                                                                       |

**🔗 MERGE POINT 2 (12:30):** Push generation. E3b wires review screen to real generated output.

**Done when:** Full pipeline produces all 5 markdown sections from a URL.

---

## Phase 3 (13:55–14:30) — Improvements + Fallback

| #   | Task                                                                  | Status | Notes                                             |
| --- | --------------------------------------------------------------------- | ------ | ------------------------------------------------- |
| 20  | Add `suggest_improvements!` method                                    | ⬜     | LLM reviews generated config, returns suggestions |
| 21  | Pre-cache LLM responses for demo fallback                             | ⬜     | Black Bag Exemption + DVLA Motor Caravan          |
| 22  | Add fallback logic: if `LlmClient.available?` is false, return cached | ⬜     |                                                   |

**Done when:** Pipeline works live AND with cached fallback.

---

## Key Schemas

### CaseTypeConfig

```ruby
create_table :case_type_configs do |t|
  t.string  :name, null: false
  t.string  :slug, null: false
  t.text    :description
  t.string  :organisation
  t.integer :status, default: 0                   # draft, published, archived
  t.integer :default_sla_days
  t.text    :decision_tree_md, null: false
  t.text    :state_transitions_md, null: false
  t.text    :evidence_requirements_md
  t.text    :correspondence_templates_md
  t.text    :risk_scoring_md
  t.text    :source_metadata, default: '{}'       # JSON string (SQLite)
  t.references :created_by, foreign_key: { to_table: :caseworkers }
  t.timestamps
end
add_index :case_type_configs, :slug, unique: true
```

### CaseTypeGenerationLog

```ruby
create_table :case_type_generation_logs do |t|
  t.references :case_type_config, null: false, foreign_key: true
  t.integer :step, null: false
  t.string  :step_name, null: false
  t.text    :input_text
  t.text    :output_text
  t.string  :model_used
  t.integer :tokens_used
  t.float   :confidence_score
  t.timestamps
end
```

---

## LLM Prompts

### Analysis Prompt (Step 2)

```text
Given this text describing a government process, identify:
1. The case type name and short description
2. Who applies / who is the applicant
3. Who decides / who is the caseworker
4. What evidence or information is required
5. What are the eligibility criteria / decision points
6. What are the possible outcomes
7. What is the typical timeline / SLA
8. What communication happens with the applicant
9. Confidence score (0-1) for each element
10. If any element has confidence < 0.6, list specific clarifying questions with 2-4 suggested options each

Return as JSON.
```

### Generation Prompt (Step 3)

```text
Using this analysis of a government process, generate a complete case type configuration. Return each section in markdown:

A) DECISION_TREE — sequential checks with YES/NO branches → GRANT/REFUSE
B) STATE_TRANSITIONS — table: Current State | Trigger | Next State | Action
C) EVIDENCE_REQUIREMENTS — table: Evidence | Required? | Source | Verification Method
D) CORRESPONDENCE_TEMPLATES — templates for key communications
E) RISK_SCORING — rules for calculating risk score

Return as JSON with keys: decision_tree_md, state_transitions_md, evidence_requirements_md, correspondence_templates_md, risk_scoring_md, name, slug, description, default_sla_days
```
