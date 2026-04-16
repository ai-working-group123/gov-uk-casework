# E3b — Frontend: Controller, Views & UI

## Your Role

You build the **interface** — the admin screens that let users input a process, see clarifying questions, review generated output, and publish. E3a builds the services you call. You work in parallel using stubbed responses until E3a's services are ready.

**Your files — nobody else touches these:**

| Layer | Files |
|-------|-------|
| **Routes** | Admin namespace in `config/routes.rb` |
| **Controller** | `app/controllers/admin/case_type_configs_controller.rb` |
| **Views** | `app/views/admin/case_type_configs/` — `new`, `questions`, `review`, `index`, `show` |
| **Layout** | `app/views/layouts/admin.html.erb` |
| **Helpers** | `app/helpers/admin/case_type_configs_helper.rb` (markdown rendering) |

---

## Stubbing Strategy (until E3a delivers services)

Create `app/services/case_type_generator_stub.rb` with hardcoded return values so you can build all screens without waiting for the real LLM pipeline. Delete the stub once you integrate.

```ruby
# app/services/case_type_generator_stub.rb
class CaseTypeGeneratorStub
  def initialize(case_type_config) = @config = case_type_config

  def scrape_and_analyse!
    {
      name: "Black Bag Limit Exemption",
      description: "Residents apply for exemption to 3 black bag limit",
      applicant_type: "Resident",
      caseworker_type: "Waste enforcement officer",
      evidence_requirements: ["Photo of waste area", "Proof of household size"],
      eligibility_criteria: ["Non-recyclable waste", "Medical waste", "Nappies"],
      possible_outcomes: ["Approved", "Refused", "Approved with conditions"],
      typical_timeline: "14 days",
      communication_steps: ["Acknowledge receipt", "Request evidence", "Decision letter"],
      confidence_scores: { name: 0.95, evidence: 0.5, timeline: 0.7 },
      clarifying_questions: [
        { question: "What defines 'non-recyclable' waste in this context?",
          options: ["Pet waste only", "All non-kerbside items", "Medical + pet + nappies"],
          element: "eligibility" },
        { question: "Is a home visit required before approval?",
          options: ["Always", "Sometimes (officer discretion)", "Never"],
          element: "evidence" }
      ]
    }
  end

  def generate_config!(answers: {})
    @config.update!(
      name: "Black Bag Limit Exemption",
      slug: "black_bag_exemption",
      description: "Residents apply for exemption to the 3 black bag limit",
      default_sla_days: 14,
      decision_tree_md: "START\n│\n├─ Is waste non-recyclable?\n│   ├─ NO → REFUSE\n│   └─ YES ↓\n├─ Evidence provided?\n│   ├─ NO → REQUEST\n│   └─ YES → APPROVE",
      state_transitions_md: "| Current | Trigger | Next | Action |\n|---|---|---|---|\n| Submitted | Auto-assign | Assigned | Notify officer |",
      evidence_requirements_md: "| Evidence | Required? | Source |\n|---|---|---|\n| Photo of waste | Mandatory | Applicant |",
      correspondence_templates_md: "## Acknowledgement\nDear {{ applicant_name }},\nWe have received your application...",
      risk_scoring_md: "- SLA approaching: +25\n- Evidence missing: +20"
    )
    @config
  end
end
```

Use `CaseTypeGeneratorStub` in your controller until merge point 1, then swap to `CaseTypeGenerator`.

---

## Pre-Build (08:30–09:55)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Add gem: `redcarpet` to Gemfile, `bundle install` | ⬜ | Coordinate with E3a who adds LLM gem |
| 2 | Add admin routes to `config/routes.rb` | ⬜ | See routes below |
| 3 | Create admin layout `app/views/layouts/admin.html.erb` | ⬜ | Blue header, distinct from caseworker |
| 4 | Create stub service `app/services/case_type_generator_stub.rb` | ⬜ | Hardcoded responses for all screens |
| 5 | Create `app/helpers/admin/case_type_configs_helper.rb` | ⬜ | Markdown → HTML rendering helper |

**Done when:** Admin layout renders. Stub returns data. You can build screens.

---

## Phase 1 (09:55–11:00) — Input + Questions Screens

| # | Task | Status | Notes |
|---|------|--------|-------|
| 6 | Create `app/controllers/admin/case_type_configs_controller.rb` | ⬜ | Actions: `index`, `new`, `create`, `questions`, `answer`, `review`, `publish`, `regenerate` |
| 7 | Create `new.html.erb` — input form | ⬜ | Description textarea + URL field + "Analyse & Generate" button |
| 8 | Create `create` action — saves config, calls `scrape_and_analyse!` | ⬜ | Use stub initially, redirect to questions |
| 9 | Create `questions.html.erb` — clarifying questions UI | ⬜ | Radio buttons for options, free text override, "Skip" button |
| 10 | Create `answer` action — collects answers, calls `generate_config!` | ⬜ | Redirect to review |
| 11 | Add progress indicator (Steps 1-4 bar at top of each page) | ⬜ | Simple: "Step 1 of 4: Describe Process" etc |

**🔗 MERGE POINT 1 (11:00):** Pull E3a's services. Swap stub → `CaseTypeGenerator` in controller.

**Done when:** Full input → questions flow works with stub data.

---

## Phase 2 (11:40–12:30) — Review Screen

| # | Task | Status | Notes |
|---|------|--------|-------|
| 12 | Create `review.html.erb` — side-by-side view | ⬜ | Left: source/analysis. Right: generated markdown (rendered) |
| 13 | Add editable textareas for each section | ⬜ | Toggle between rendered markdown and raw editor |
| 14 | Wire up `regenerate` action — re-run one section via LLM | ⬜ | Button per section: "🔄 Regenerate" |
| 15 | Add inline markdown preview (Redcarpet rendering in helper) | ⬜ | |
| 16 | Add "Save Draft" and "Publish" buttons on review page | ⬜ | |

**🔗 MERGE POINT 2 (12:30):** Pull E3a's generation. Review screen shows real LLM output.

**Done when:** Review screen renders all 5 sections with edit + preview capability.

---

## Phase 3 (13:55–14:30) — Publish, Index & Polish

| # | Task | Status | Notes |
|---|------|--------|-------|
| 17 | Create `publish` action — sets status to published | ⬜ | |
| 18 | Create `index.html.erb` — list of published case types | ⬜ | Cards with name, org, status, SLA, created date |
| 19 | Create `show.html.erb` — read-only view of published config | ⬜ | All 5 sections rendered as markdown |
| 20 | Add Turbo Frame for progress steps (✅ ✅ ⏳) | ⬜ | Optional polish — only if time |
| 21 | Add process improvement suggestions panel on review | ⬜ | Display suggestions from E3a's `suggest_improvements!`, accept/reject buttons |
| 22 | Visual polish — GOV.UK-consistent styling throughout | ⬜ | |

**Done when:** Full pipeline end-to-end. Published configs listed in index.

---

## Demo Prep (14:30–15:00)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 23 | Walk through demo script with E3a | ⬜ | Primary: Black Bag Exemption |
| 24 | Test DVLA Motor Caravan as second example | ⬜ | Shows versatility |
| 25 | Verify fallback cached responses render correctly | ⬜ | Coordinate with E3a |

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

## Screen Specs

### `new.html.erb` — Input Form

```
┌─────────────────────────────────────────────────┐
│  Step 1 of 4: Describe the Process              │
├─────────────────────────────────────────────────┤
│                                                  │
│  Description (optional if URL provided)          │
│  ┌────────────────────────────────────────────┐ │
│  │ textarea — describe the process...         │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  URL to existing process page (optional)         │
│  ┌────────────────────────────────────────────┐ │
│  │ https://...                                │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  Organisation                                    │
│  ┌────────────────────────────────────────────┐ │
│  │ e.g. Swansea Council, DVLA                 │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│            [ Analyse & Generate → ]              │
└─────────────────────────────────────────────────┘
```

### `questions.html.erb` — Clarifying Questions

```
┌─────────────────────────────────────────────────┐
│  Step 2 of 4: Clarifying Questions               │
├─────────────────────────────────────────────────┤
│                                                  │
│  We're fairly confident about this process but   │
│  need to clarify a few things:                   │
│                                                  │
│  1. What defines 'non-recyclable' waste?         │
│     ○ Pet waste only                             │
│     ○ All non-kerbside items                     │
│     ○ Medical + pet + nappies                    │
│     ○ Other: [________]                          │
│                                                  │
│  2. Is a home visit required?                    │
│     ○ Always                                     │
│     ○ Sometimes (officer discretion)             │
│     ○ Never                                      │
│     ○ Other: [________]                          │
│                                                  │
│  [ Skip — use best judgement ]  [ Submit → ]     │
└─────────────────────────────────────────────────┘
```

### `review.html.erb` — Side-by-Side Review

```
┌─────────────────────────────────────────────────┐
│  Step 3 of 4: Review Generated Configuration     │
├────────────────────┬────────────────────────────┤
│  Source Analysis    │  Generated Config          │
│                     │                            │
│  Name: Black Bag..  │  ┌── Decision Tree ──────┐│
│  Applicant: Resi..  │  │ START                  ││
│  Officer: Waste..   │  │ ├── Eligible? ...      ││
│  Evidence: ...      │  │ └── APPROVE/REFUSE     ││
│  Timeline: 14d      │  │ [Edit] [🔄 Regenerate] ││
│                     │  └───────────────────────┘│
│                     │  ┌── State Transitions ──┐│
│                     │  │ table...               ││
│                     │  │ [Edit] [🔄 Regenerate] ││
│                     │  └───────────────────────┘│
│                     │  ┌── Evidence Reqs ──────┐│
│                     │  │ table...               ││
│                     │  │ [Edit] [🔄 Regenerate] ││
│                     │  └───────────────────────┘│
├────────────────────┴────────────────────────────┤
│  [ Save Draft ]                  [ Publish → ]   │
└─────────────────────────────────────────────────┘
```

### `index.html.erb` — Published Case Types

```
┌─────────────────────────────────────────────────┐
│  Case Type Configurations                        │
│                                    [ + New → ]   │
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │
│  │ Black Bag Limit Exemption                 │  │
│  │ Swansea Council · SLA: 14 days · Published│  │
│  │ Created 16 Apr 2026                       │  │
│  │                          [View] [Edit]    │  │
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │ Motor Caravan Conversion                  │  │
│  │ DVLA · SLA: 28 days · Draft               │  │
│  │ Created 16 Apr 2026                       │  │
│  │                          [View] [Edit]    │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```
