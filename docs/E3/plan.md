# E3 — AI Case Type Builder: Build Plan

> **This plan is split for parallel development. See:**
> - [plan-e3a-backend.md](plan-e3a-backend.md) — **E3a**: Services, models, LLM pipeline
> - [plan-e3b-frontend.md](plan-e3b-frontend.md) — **E3b**: Controller, views, routes, UI
>
> **Merge points:** 11:00 (analysis pipeline) and 12:30 (generation pipeline)

## Your Mission

Build the "wow" feature: an admin pastes a URL or description of a government process → the system scrapes it, analyses it with an LLM, asks clarifying questions, then generates a complete case type config (decision tree, states, evidence requirements, correspondence templates). No code. No developer.

**This is what turns "we built a visa tool" into "we built a configurable casework engine any department can adopt in minutes."**

---

## The Split

| Role | Person | Scope | Files |
|------|--------|-------|-------|
| **E3a — Backend** | TBD | Services, models, migrations, LLM prompts, fallback caching | `app/services/`, `app/models/case_type_*` |
| **E3b — Frontend** | TBD | Controller, views, layout, routes, markdown rendering, UI polish | `app/controllers/admin/`, `app/views/admin/`, `app/views/layouts/admin.html.erb` |

**E3b stubs service responses** with `CaseTypeGeneratorStub` until E3a delivers. No blocking.

### Merge Points

| Time | What | Who Pulls |
|------|------|-----------|
| **11:00** | E3a pushes working `scrape_and_analyse!` | E3b swaps stub → real service |
| **12:30** | E3a pushes working `generate_config!` | E3b wires review to real output |
| **14:30** | Both integrate improvements + fallback | Joint demo rehearsal |

### Shared Gemfile Edits (coordinate — one PR)

- E3a adds: `ruby-openai` (or `anthropic`)
- E3b adds: `redcarpet`

---

## What You Own

| Layer | Files |
|-------|-------|
| **Services** | `app/services/llm_client.rb`, `app/services/url_scraper.rb`, `app/services/case_type_generator.rb` |
| **Models** | `CaseTypeConfig`, `CaseTypeGenerationLog` (migrations + model files) |
| **Controller** | `app/controllers/admin/case_type_configs_controller.rb` |
| **Views** | `app/views/admin/case_type_configs/` — `new`, `questions`, `review`, `index` |
| **Layout** | `app/views/layouts/admin.html.erb` (blue header, visually distinct from caseworker views) |

No dependency on E1/E2/E4 work. You operate in the `/admin` namespace entirely.

---

## Pre-Build (08:30–09:55)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Add gems: `ruby-openai` (or `anthropic`), `nokogiri` (already bundled), `redcarpet` | ⬜ | |
| 2 | Confirm LLM API key works — test round-trip from Rails console | ⬜ | ENV: `OPENAI_API_KEY` or `ANTHROPIC_API_KEY`, `LLM_PROVIDER` |
| 3 | Create migration `create_case_type_configs` | ⬜ | See schema below |
| 4 | Create migration `create_case_type_generation_logs` | ⬜ | See schema below |
| 5 | Create `CaseTypeConfig` + `CaseTypeGenerationLog` models | ⬜ | |
| 6 | Create `app/services/llm_client.rb` | ⬜ | Thin wrapper, one public method |
| 7 | Create `app/services/url_scraper.rb` | ⬜ | Nokogiri, strip chrome, 5000 char limit |
| 8 | Run `rails db:migrate`, verify models work in console | ⬜ | |

**Done when:** LLM call returns a response from the app. Models exist in DB.

---

## Phase 1 (09:55–11:00) — Input + Analysis Pipeline

| # | Task | Status | Notes |
|---|------|--------|-------|
| 9 | Create `app/services/case_type_generator.rb` — orchestrator | ⬜ | `scrape_and_analyse!` + `generate_config!` |
| 10 | Add admin routes to `config/routes.rb` | ⬜ | See routes below |
| 11 | Create `app/controllers/admin/case_type_configs_controller.rb` | ⬜ | `new`, `create`, `questions`, `answer`, `review`, `publish`, `index` |
| 12 | Create admin layout `app/views/layouts/admin.html.erb` | ⬜ | Blue header, "Case Management Service — Admin" |
| 13 | Create `new.html.erb` — input form (description textarea + URL field) | ⬜ | |
| 14 | Create `questions.html.erb` — clarifying questions UI | ⬜ | Render if confidence < 0.6, skip button |
| 15 | Test: paste URL → scrape → analyse → questions render | ⬜ | |

**Done when:** Admin can paste a URL → system scrapes + analyses → shows clarifying questions.

---

## Phase 2 (11:40–12:30) — Generation + Review

| # | Task | Status | Notes |
|---|------|--------|-------|
| 16 | Build generation step in `case_type_generator.rb` | ⬜ | LLM produces decision tree, states, evidence, templates, risk scoring |
| 17 | Create `review.html.erb` — side-by-side view | ⬜ | Source material \| generated output, editable textareas with markdown preview |
| 18 | Wire up `regenerate` action — re-run a single section | ⬜ | |
| 19 | Test end-to-end: input → scrape → analyse → questions → generate → review | ⬜ | |

**Done when:** Admin sees generated config and can edit each section.

---

## Phase 3 (13:55–14:30) — Publish + Polish

| # | Task | Status | Notes |
|---|------|--------|-------|
| 20 | Add `publish` action — saves as published, appears in index | ⬜ | |
| 21 | Create `index.html.erb` — list of published case types | ⬜ | |
| 22 | Add progress UI (✅ Step 1... ✅ Step 2... ⏳ Step 3...) | ⬜ | Turbo frames or simple polling |
| 23 | Add process improvement suggestions panel (LLM reviews + suggests) | ⬜ | Accept/reject each suggestion |
| 24 | Pre-cache LLM responses as fallback for demo | ⬜ | If API slow/down during demo |

**Done when:** Full pipeline works end-to-end. Publish flow works.

---

## Demo Prep (14:30–15:00)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 25 | Rehearse demo with Black Bag Exemption URL | ⬜ | Primary demo case type |
| 26 | Prepare DVLA Motor Caravan as second demo case type | ⬜ | Shows versatility |
| 27 | Ensure fallback cached responses work if API fails | ⬜ | |

---

## Key Schemas

### CaseTypeConfig

```ruby
create_table :case_type_configs do |t|
  t.string  :name, null: false                    # "Black Bag Limit Exemption"
  t.string  :slug, null: false                    # "black_bag_exemption"
  t.text    :description
  t.string  :organisation                         # "Swansea Council", "DVLA"
  t.integer :status, default: 0                   # draft, published, archived
  t.integer :default_sla_days
  t.text    :decision_tree_md, null: false
  t.text    :state_transitions_md, null: false
  t.text    :evidence_requirements_md
  t.text    :correspondence_templates_md
  t.text    :risk_scoring_md
  t.text    :source_metadata, default: '{}'       # JSON string (SQLite has no jsonb)
  t.references :created_by, foreign_key: { to_table: :caseworkers }
  t.timestamps
end
add_index :case_type_configs, :slug, unique: true
```

### CaseTypeGenerationLog

```ruby
create_table :case_type_generation_logs do |t|
  t.references :case_type_config, null: false, foreign_key: true
  t.integer :step, null: false          # 1=scrape, 2=analyse, 3=generate, 4=review
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

## Routes (add to `config/routes.rb`)

```ruby
namespace :admin do
  resources :case_type_configs do
    member do
      get :questions
      post :answer
      get :review
      post :publish
      post :regenerate
    end
  end
end
```

---

## LLM Prompts (have these ready as constants)

### Analysis Prompt (Step 2)

> Given this text describing a government process, identify:
> 1. The case type name and short description
> 2. Who applies / who is the applicant
> 3. Who decides / who is the caseworker
> 4. What evidence or information is required
> 5. What are the eligibility criteria / decision points
> 6. What are the possible outcomes
> 7. What is the typical timeline / SLA
> 8. What communication happens with the applicant
> 9. Confidence score (0-1) for each element
> 10. If any element has confidence < 0.6, list specific clarifying questions with 2-4 suggested options each
>
> Return as JSON.

### Generation Prompt (Step 3)

> Using this analysis of a government process, generate a complete case type configuration. Return each section in markdown:
>
> A) DECISION_TREE — sequential checks with YES/NO branches → GRANT/REFUSE
> B) STATE_TRANSITIONS — table: Current State | Trigger | Next State | Action
> C) EVIDENCE_REQUIREMENTS — table: Evidence | Required? | Source | Verification Method
> D) CORRESPONDENCE_TEMPLATES — templates for key communications
> E) RISK_SCORING — rules for calculating risk score
>
> Return as JSON with keys: decision_tree_md, state_transitions_md, evidence_requirements_md, correspondence_templates_md, risk_scoring_md, name, slug, description, default_sla_days

---

## Demo Script

1. Open `/admin/case_type_configs/new`
2. Paste Swansea black bag exemption URL
3. Hit "Analyse & Generate"
4. Show progress steps completing
5. Answer 1-2 clarifying questions (or skip)
6. Show generated decision tree, evidence table, templates
7. Edit one section to show it's human-editable
8. Hit "Publish"
9. Show it in the published list
10. **If time:** repeat with DVLA Motor Caravan to show versatility

**Fallback:** If API is down, pre-cached responses kick in. Mention: "In production this calls Claude/GPT-4o; we've pre-generated outputs to avoid API latency."

---

## Decision: Which LLM?

| Option | Gem | ENV var | Model |
|--------|-----|---------|-------|
| OpenAI | `ruby-openai` | `OPENAI_API_KEY` | `gpt-4o` |
| Anthropic | `anthropic` | `ANTHROPIC_API_KEY` | `claude-sonnet-4` |

Set `LLM_PROVIDER=openai` or `LLM_PROVIDER=anthropic` in ENV. Default to OpenAI.
