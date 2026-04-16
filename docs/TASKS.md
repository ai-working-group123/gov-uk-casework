# Task Breakdown — Challenge 3: Hack Day

Each task is labelled:

- 🤖 **AI-first** — use Copilot/agent with the provided prompt. Human reviews output.
- 🧑 **Human** — manual task, requires human judgement or physical action.
- 🤖🧑 **AI-assisted** — human drives, AI accelerates (e.g. Copilot inline completions while coding).

Prompts reference project docs: `DATA_MODEL.md`, `SEED_DATA_STRATEGY.md`, `UX_WIREFRAMES.md`, `AI_CASE_TYPE_BUILDER.md`, `CHALLENGE_3_ANALYSIS.md`.

---

## Phase 0: Night Before (All Engineers)

### T-0.1 — Environment Setup

| #   | Task                                                                                                         | Type     | Owner |
| --- | ------------------------------------------------------------------------------------------------------------ | -------- | ----- |
| 0.1 | Install Ruby 3.3+, Rails 8+, Git. Verify `rails new test_app --css tailwind && cd test_app && bin/dev` boots | 🧑 Human | ALL   |
| 0.2 | Install VS Code + GitHub Copilot. Verify Copilot completions work in a `.rb` file                            | 🧑 Human | ALL   |
| 0.3 | Create GitHub repo `casework`. Add all team members as collaborators. Clone locally.                         | 🧑 Human | E1    |
| 0.4 | Read PLAN.md, DATA_MODEL.md, SEED_DATA_STRATEGY.md, UX_WIREFRAMES.md                                         | 🧑 Human | ALL   |
| 0.5 | E3: Confirm LLM API key works. Run a test completion call from Ruby (see Task 0.6)                           | 🧑 Human | E3    |

### T-0.6 — E3: Test LLM API Access

| #   | Task                          | Type             | Owner |
| --- | ----------------------------- | ---------------- | ----- |
| 0.6 | Test LLM round-trip from Ruby | 🤖🧑 AI-assisted | E3    |

```
Write a standalone Ruby script that:
1. Requires the 'openai' gem (or 'anthropic' gem, depending on API choice)
2. Reads API key from ENV var OPENAI_API_KEY (or ANTHROPIC_API_KEY)
3. Sends a simple completion request: "You are a government process analyst. Describe the steps in processing a visa application in 3 bullet points."
4. Prints the response to stdout
5. Exits 0 on success, 1 on failure with error message

This is a smoke test — if it prints 3 bullet points, the API works.
```

---

## Phase 1: Pre-Build — 08:30–09:55 (Before Build Clock Starts)

### E1 Tasks: Foundation

| #   | Task               | Type     | Owner | Depends On |
| --- | ------------------ | -------- | ----- | ---------- |
| 1.1 | Scaffold Rails app | 🧑 Human | E1    | —          |

```bash
rails new casework --css tailwind
cd casework
```

| #   | Task                | Type        | Owner | Depends On |
| --- | ------------------- | ----------- | ----- | ---------- |
| 1.2 | Add gems to Gemfile | 🤖 AI-first | E1    | 1.1        |

**Prompt:**

```
Add the following gems to the Gemfile of this Rails 8 app:

- chartkick (for charts)
- groupdate (for date grouping in queries)
- redcarpet (for markdown rendering)

If using OpenAI: ruby-openai
If using Anthropic: anthropic

Do not add any other gems. Do not remove existing gems.
```

| #   | Task                             | Type        | Owner | Depends On |
| --- | -------------------------------- | ----------- | ----- | ---------- |
| 1.3 | Generate all models + migrations | 🤖 AI-first | E1    | 1.2        |

**Prompt:**

```
I'm building a UK government casework management system in Rails 8. Read the
file DATA_MODEL.md in this project — it contains the complete data model with
all migrations and ActiveRecord models.

Generate ALL migration files exactly as specified in DATA_MODEL.md:
- 001_create_teams.rb through 011_create_case_type_generation_logs.rb
- Include all columns, types, indexes, and foreign keys exactly as documented

Then generate ALL model files exactly as specified in DATA_MODEL.md:
- Team, Caseworker, Case, Evidence, CaseNote, Action, Correspondence,
  PolicyReference, EvidenceRequest, EvidenceRequestItem, CaseTypeConfig,
  CaseTypeGenerationLog
- Include all associations, enums, scopes, and methods documented

Place migrations in db/migrate/ and models in app/models/.
Follow Rails 8 conventions. Use the exact enum definitions and scope
definitions from DATA_MODEL.md.
```

| #   | Task            | Type        | Owner | Depends On |
| --- | --------------- | ----------- | ----- | ---------- |
| 1.4 | Generate routes | 🤖 AI-first | E1    | 1.3        |

**Prompt:**

```
Read DATA_MODEL.md in this project — it contains the complete routes definition
under "Routes & Controllers".

Generate config/routes.rb exactly as specified, including:
- Caseworker resources (cases, notes, actions, evidences, evidence_requests)
- Dashboard namespace (caseworker, team, overview)
- Public applicant portal routes (lookup)
- Policy reference routes
- Admin namespace for case type configs:

  namespace :admin do
    resources :case_type_configs do
      member do
        get :questions      # Step 2b: clarifying questions
        post :answer        # Submit answers to questions
        get :review         # Step 4: review generated config
        post :publish       # Publish the config
        post :regenerate    # Regenerate a section
      end
    end
  end

Set root to "cases#index".
```

### E2 Tasks: Layout

| #   | Task                                   | Type        | Owner | Depends On        |
| --- | -------------------------------------- | ----------- | ----- | ----------------- |
| 1.5 | Create GOV.UK-style application layout | 🤖 AI-first | E2    | 1.1 (repo cloned) |

**Prompt:**

```
I'm building a UK government casework system in Rails 8 with Tailwind CSS.

Create app/views/layouts/application.html.erb with a GOV.UK-inspired design:

1. Header bar: dark background (#0b0c0c), white text, service name
   "Case Management Service" on the left, mock user name + "Sign out" on the
   right. Use the GDS Transport-style font feel via Tailwind — clean,
   sans-serif.

2. Main content area: max-width container (max-w-6xl), white background,
   generous padding.

3. Footer: simple grey bar with "Built for the AI Engineering Lab Hackathon"

4. Use Tailwind utility classes throughout. No custom CSS files.

5. Include a `<%= yield %>` in the main content area.

6. The header should have a nav-style layout with the service name as a link
   to root_path.

7. Make it clean, minimal, high-contrast, accessible — GOV.UK design
   principles.

Also create a separate admin layout at app/views/layouts/admin.html.erb —
same structure but header says "Case Management Service — Admin" and uses a
slightly different accent colour (e.g. blue header instead of black) so it's
visually distinct from the caseworker views.
```

### E3 Tasks: LLM Foundation

| #   | Task                           | Type        | Owner | Depends On        |
| --- | ------------------------------ | ----------- | ----- | ----------------- |
| 1.6 | Create LlmClient service class | 🤖 AI-first | E3    | 1.1 (repo cloned) |

**Prompt:**

```
Create app/services/llm_client.rb — a thin Ruby service class that wraps
LLM API calls for a Rails 8 app.

Requirements:
- Reads API key from ENV var (OPENAI_API_KEY or ANTHROPIC_API_KEY)
- Has a single public method: `call(system_prompt:, user_prompt:, max_completion_tokens: 4000)`
- Returns the text content of the response as a string
- Handles API errors gracefully — raises a custom LlmClient::Error with
  a useful message
- Has a class method `available?` that returns true if the API key is
  configured
- Has a class method `model_name` that returns the model being used
  (e.g. "gpt-4o" or "claude-sonnet-4")

Use the ruby-openai gem (or anthropic gem). Keep it simple — no retries,
no streaming, no fancy error handling. This is a hackathon.

If ENV['LLM_PROVIDER'] == 'anthropic', use the Anthropic client.
Otherwise default to OpenAI.
```

| #   | Task                      | Type        | Owner | Depends On |
| --- | ------------------------- | ----------- | ----- | ---------- |
| 1.7 | Create UrlScraper service | 🤖 AI-first | E3    | 1.1        |

**Prompt:**

```
Create app/services/url_scraper.rb — a service that fetches a web page and
extracts its main content.

Requirements:
- Method: `call(url)` — returns a string of cleaned text content
- Use Net::HTTP to fetch the page (no extra gems needed)
- Use Nokogiri to parse HTML
- Strip navigation, footer, cookie banners, scripts, styles
- Extract the main content area (look for <main>, <article>,
  role="main", or fall back to <body>)
- Convert to clean text: strip HTML tags, collapse whitespace,
  preserve paragraph breaks
- Limit output to 5000 characters (enough for LLM context without
  burning tokens)
- Handle errors (404, timeout, SSL) — raise UrlScraper::Error with
  a clear message
- Set a reasonable User-Agent header and 10-second timeout
```

| #   | Task                                          | Type        | Owner | Depends On |
| --- | --------------------------------------------- | ----------- | ----- | ---------- |
| 1.8 | Create CaseTypeGenerator orchestrator service | 🤖 AI-first | E3    | 1.6, 1.7   |

**Prompt:**

```
Create app/services/case_type_generator.rb — the orchestrator for the
AI Case Type Builder pipeline, as described in AI_CASE_TYPE_BUILDER.md.

This service manages a 4-step pipeline:
1. SCRAPE: If URLs provided, use UrlScraper to fetch and extract content
2. ANALYSE: Send content to LLM to identify the process structure
3. GENERATE: Send analysis to LLM to produce decision tree, states,
   evidence, templates
4. (Review is handled by the UI, not this service)

Class: CaseTypeGenerator
Initialize with: `case_type_config` (a CaseTypeConfig ActiveRecord record)

Methods:
- `scrape_and_analyse!` — runs Steps 1+2. Updates the CaseTypeConfig with
  analysis results stored in `source_metadata` jsonb field. Creates
  CaseTypeGenerationLog entries for each step. Returns the analysis as a
  Hash with keys: name, description, applicant_type, caseworker_type,
  evidence_requirements, eligibility_criteria, possible_outcomes,
  typical_timeline, communication_steps, confidence_scores,
  clarifying_questions (array of questions if confidence < 0.6)

- `generate_config!(answers: {})` — runs Step 3. Takes optional answers
  hash from clarifying questions. Sends enriched analysis to LLM with
  generation prompt. Updates CaseTypeConfig with:
  - decision_tree_md
  - state_transitions_md
  - evidence_requirements_md
  - correspondence_templates_md
  - risk_scoring_md
  Creates CaseTypeGenerationLog for this step.

The ANALYSIS PROMPT (Step 2) should be:
"Given this text describing a government process, identify:
1. The case type name and short description
2. Who applies / who is the applicant
3. Who decides / who is the caseworker
4. What evidence or information is required
5. What are the eligibility criteria / decision points
6. What are the possible outcomes
7. What is the typical timeline / SLA
8. What communication happens with the applicant
9. Confidence score (0-1) for each element
10. If any element has confidence < 0.6, list specific clarifying questions
    with 2-4 suggested multiple choice options each

Return as JSON."

The GENERATION PROMPT (Step 3) should be:
"Using this analysis of a government process, generate a complete case type
configuration. Return each section in markdown format:

A) DECISION_TREE: A markdown decision tree showing the sequential checks
   and branch points, using the format:
   START → Check 1 → YES/NO branches → next checks → GRANT/REFUSE outcomes

B) STATE_TRANSITIONS: A markdown table with columns:
   Current State | Trigger | Next State | Action

C) EVIDENCE_REQUIREMENTS: A markdown table with columns:
   Evidence | Required? | Source | Verification Method

D) CORRESPONDENCE_TEMPLATES: Markdown templates for key communications
   (application received, evidence requested, decision made)

E) RISK_SCORING: Markdown rules for calculating risk score

Return as JSON with keys: decision_tree_md, state_transitions_md,
evidence_requirements_md, correspondence_templates_md, risk_scoring_md,
name, slug, description, default_sla_days"

Store each LLM call's input, output, model, and token usage in
CaseTypeGenerationLog.
```

### E4 Tasks: Seeds + Routes

| #   | Task                      | Type        | Owner | Depends On         |
| --- | ------------------------- | ----------- | ----- | ------------------ |
| 1.9 | Generate seed data script | 🤖 AI-first | E4    | 1.3 (models exist) |

**Prompt:**

```
Read the files SEED_DATA_STRATEGY.md and CHALLENGE_3_ANALYSIS.md in this
project. They contain the complete seed data specification and domain
knowledge for a UK visa casework management system.

Generate db/seeds.rb that creates:

1. ONE team: "Visa Processing Unit" led by James Morton

2. FIVE caseworkers exactly as specified in SEED_DATA_STRATEGY.md:
   - Sarah Chen (12 cases, 1 overdue)
   - Fatima Ali (15 cases, 3 overdue — she's overloaded)
   - David Park (9 cases, all on track)
   - Tom Hughes (5 cases — light load, available for rebalancing)
   - Nia Williams (6 cases, 1 approaching SLA)

3. FIVE named demo cases exactly as in SEED_DATA_STRATEGY.md:
   - VIS-2024-00847 Priya Sharma — Tier 2 Work, OVERDUE, missing
     sponsorship cert, 13 days past SLA
   - VIS-2024-00891 Marco Rossi — Tier 4 Student, action needed,
     docs ready for review
   - VIS-2024-00902 Aisha Hassan — Family Visa, on track, progressing
     normally
   - VIS-2024-00923 James O'Brien — Tier 4 Student, new, just submitted
   - VIS-2024-00734 Li Wei — Settlement, OVERDUE, stuck in review

4. 42 additional cases distributed across caseworkers to reach 47 total,
   matching the distribution above. Use realistic names, varied
   nationalities, mix of case types and statuses.

5. EVIDENCE items for each case (4-6 per case). For the 5 named demo
   cases, use the exact evidence listed in the wireframes:
   - Priya Sharma: passport ✅, English language ✅, TB cert ✅,
     bank statements ✅, sponsorship cert ❌ (not received),
     biometrics ⬜ (not yet required)

6. POLICY REFERENCES: All Skilled Worker policies from
   SEED_DATA_STRATEGY.md (SW, SW-COS-VALID, SW-SALARY, SW-ENGLISH,
   SW-MAINTENANCE, SW-TB). Add Student and Family visa policies too.

7. ACTIONS for the 5 named cases. Priya should have:
   - "Chase missing evidence: sponsorship certificate" (overdue,
     linked to SW-COS-VALID)
   - "Review financial evidence once sponsorship received" (blocked)

8. CASE NOTES for the 5 named cases creating the timeline shown in
   UX_WIREFRAMES.md Screen 2. Include system notes for assignment
   and SLA deadline passing.

9. At least 200 case notes total across all 47 cases for realistic
   timelines.

Use Time.current-based date arithmetic so dates are relative to today.
Set SLA deadlines realistically: Tier 2 = 8 weeks, Student = 3 weeks,
Family = 12 weeks, Settlement = 26 weeks from submission.

Make it idempotent: start with model.destroy_all calls at the top.
```

---

## Phase 2: Build Phase 1 — 09:55 to 10:40 (First Journey)

### E1 Tasks: Controllers + Data

| #   | Task                                | Type     | Owner | Depends On |
| --- | ----------------------------------- | -------- | ----- | ---------- |
| 2.1 | Run migrations + seeds, verify data | 🧑 Human | E1    | 1.3, 1.9   |

```bash
rails db:migrate && rails db:seed
rails console -e development
# Quick checks:
Case.count          # => 47
Caseworker.count    # => 5
Evidence.count      # => ~280
CaseNote.count      # => ~200+
PolicyReference.count  # => ~15+
```

| #   | Task                                       | Type        | Owner | Depends On |
| --- | ------------------------------------------ | ----------- | ----- | ---------- |
| 2.2 | Generate CasesController with index + show | 🤖 AI-first | E1    | 2.1        |

**Prompt:**

```
Create app/controllers/cases_controller.rb for a Rails 8 casework app.

This controls the caseworker's main views: their case list and case detail.

#index:
- Mock current user as Sarah Chen (Caseworker.find_by(name: "Sarah Chen")).
  In future this would come from authentication.
- Load cases assigned to current caseworker
- Support optional query params for filtering: status, priority, case_type
- Order: overdue cases first (sla_deadline < Time.current AND not decided/
  withdrawn), then by priority desc, then by sla_deadline asc
- Calculate summary stats for the view:
  @active_count — non-decided, non-withdrawn cases
  @action_needed_count — cases with pending actions due today or overdue
  @overdue_count — cases past SLA deadline that aren't decided/withdrawn
  @new_today_count — cases submitted today

#show:
- Load case with eager-loaded associations: evidences (with policy_reference),
  actions (with policy_reference), case_notes, evidence_requests
  (with evidence_request_items)
- @evidences grouped: received vs missing vs not_yet_required
- @actions ordered by status (pending first, then in_progress, then completed)
- @notes ordered by created_at desc (most recent first)
- @policy_references — distinct policy references related to this case type

#update:
- Allow updating status and priority only
- Redirect back to show with a flash notice

Use strong parameters. No authentication — just the mocked current user.
```

| #   | Task                         | Type        | Owner | Depends On |
| --- | ---------------------------- | ----------- | ----- | ---------- |
| 2.3 | Generate CaseNotesController | 🤖 AI-first | E1    | 2.2        |

**Prompt:**

```
Create app/controllers/case_notes_controller.rb for a Rails 8 casework app.

#create:
- Nested under cases (case_id from params)
- Create a new CaseNote with note_type: :manual
- Set caseworker to mocked current user (Sarah Chen)
- Params: content (required), visible_to_applicant (boolean, default false),
  applicant_message (optional — plain English version for applicant portal)
- On success: redirect back to case show page with flash
- On failure: redirect back with error flash

Keep it simple. No Turbo Streams yet — full page redirect is fine.
```

### E2 Tasks: Caseworker Dashboard + Case Detail

| #   | Task                                        | Type        | Owner | Depends On |
| --- | ------------------------------------------- | ----------- | ----- | ---------- |
| 2.4 | Create caseworker dashboard view (Screen 1) | 🤖 AI-first | E2    | 1.5, 2.2   |

**Prompt:**

```
Read UX_WIREFRAMES.md Screen 1 (Caseworker Dashboard) in this project.

Create app/views/cases/index.html.erb — the caseworker's morning dashboard.

Requirements, matching the wireframe:

1. GREETING: "Good morning, Sarah. Here's your caseload for today."

2. STAT CARDS ROW: Four cards in a horizontal flex row:
   - Active cases: @active_count (blue/neutral)
   - Need action today: @action_needed_count (amber if > 0)
   - Overdue: @overdue_count (red with ⚠️ URGENT if > 0)
   - New today: @new_today_count (blue)
   Each card: large number, label below, appropriate colour coding.

3. FILTER BAR: Three dropdowns (Status, Priority, Type) + search field.
   Use simple form GET params. Don't worry about Turbo Frames for now —
   full page reload on filter.

4. CASE TABLE:
   - Columns: Ref, Applicant, Type, Status, Priority
   - Status badges:
     ⚠️ OVERDUE (red bg) | 🟡 Action needed (amber) |
     🟢 On track (green) | 🔵 New (blue)
   - Priority badges: 🔴 High | 🟡 Med | 🟢 Low
   - Each row is a link to case_path(case)
   - Overdue cases should visually stand out (e.g. light red row bg)

5. PAGINATION: "Showing X of Y cases" with simple pagination
   (use Rails built-in or just show all for now)

Use Tailwind CSS. GOV.UK-inspired: clean, minimal, high contrast.
Match the visual hierarchy from the wireframe — stats at top, filters,
then table.
```

| #   | Task                               | Type        | Owner | Depends On |
| --- | ---------------------------------- | ----------- | ----- | ---------- |
| 2.5 | Create case detail view (Screen 2) | 🤖 AI-first | E2    | 2.4        |

**Prompt:**

```
Read UX_WIREFRAMES.md Screen 2 (Case Detail Page) in this project.

Create app/views/cases/show.html.erb — the case detail view.

Requirements, matching the wireframe:

1. BACK LINK: "← Back to dashboard" linking to cases_path

2. CASE SUMMARY CARD:
   - Applicant name, status badge, case type, priority badge
   - Submitted date, SLA deadline, assigned to, days overdue
     (if past SLA)
   - Bordered card with clear visual hierarchy

3. "WHAT YOU NEED TO DO" PANEL:
   - Render @actions (pending/in_progress)
   - Each action shows: priority indicator (🔴/🟡/🟢), title,
     due date with "X days ago" or "in X days", blocked_by if present
   - Action buttons: [Mark as received] [Send reminder] as simple
     button_to links (wire up later)

4. TWO-COLUMN LAYOUT below actions:

   LEFT: Evidence panel
   - List each evidence item from @evidences
   - ✅ for received/accepted, ❌ for not_received (with "⚠️ X days late"
     if past required_by date), ⬜ for not yet required
   - Show count: "X/Y received"

   RIGHT: Applicable Policy panel
   - Show @policy_references for this case type
   - Title, key criteria as bullet points
   - [View full policy →] link to govuk_url

5. CASE TIMELINE:
   - @notes ordered most recent first
   - Each entry: date, author (caseworker name or "SYSTEM" or
     "Applicant"), content
   - System notes get ⚠️ icon if they're about SLA breaches
   - [Add note] link/button at the bottom — links to a simple
     form that POSTs to case_notes_path

Use Tailwind CSS. GOV.UK-inspired design. Clean borders, good spacing,
clear visual hierarchy.

Extract reusable partials:
- app/views/cases/_evidence_panel.html.erb
- app/views/cases/_actions_panel.html.erb
- app/views/cases/_timeline.html.erb
- app/views/cases/_policy_panel.html.erb
```

### E3 Tasks: Builder Input + Analysis

| #   | Task                                    | Type        | Owner | Depends On         |
| --- | --------------------------------------- | ----------- | ----- | ------------------ |
| 2.6 | Create Admin::CaseTypeConfigsController | 🤖 AI-first | E3    | 1.3, 1.6, 1.7, 1.8 |

**Prompt:**

```
Create app/controllers/admin/case_type_configs_controller.rb for the AI
Case Type Builder.

This controller manages the pipeline: input → analyse → questions →
generate → review → publish.

Actions:

#index — list all case type configs, ordered by updated_at desc.
  Show status badge (draft/published/archived).

#new — render the input form (description textarea + URL fields)

#create — receive description + URLs, create CaseTypeConfig record,
  call CaseTypeGenerator.new(config).scrape_and_analyse!
  If analysis includes clarifying_questions, redirect to #questions.
  Otherwise redirect to #review.
  Store the analysis in source_metadata jsonb field.

#questions — render clarifying questions from the analysis
  (stored in source_metadata[:clarifying_questions])

#answer — receive answers, store them in source_metadata[:answers],
  call CaseTypeGenerator.new(config).generate_config!(answers: params[:answers])
  Redirect to #review.

#review — render the generated config (decision_tree_md,
  state_transitions_md, etc.) in editable textareas with markdown preview.

#update — save edited markdown fields.

#publish — set status to :published, redirect to #index with flash.

#regenerate — re-run generation for a specific section
  (params[:section]), update that field only.

Mock current admin user as James Morton. Use layout "admin".
Handle CaseTypeGenerator errors with flash messages and redirect back.
```

| #   | Task                           | Type        | Owner | Depends On |
| --- | ------------------------------ | ----------- | ----- | ---------- |
| 2.7 | Create builder input form view | 🤖 AI-first | E3    | 2.6        |

**Prompt:**

```
Read AI_CASE_TYPE_BUILDER.md "UI Wireframe — Case Type Builder Screen"
in this project.

Create app/views/admin/case_type_configs/new.html.erb — the input form
for the AI Case Type Builder.

Requirements matching the wireframe:

1. HEADING: "Create New Case Type"

2. DESCRIPTION SECTION:
   - Intro text: "Describe the business process in plain English, or
     paste links to existing documentation."
   - Textarea (10 rows) for free-text description, labelled "Description
     (optional)"
   - URL input field labelled "Reference URLs" with [+ Add another URL]
     button (use Stimulus for dynamic URL field adding, or just render
     3 URL fields statically)

3. SUBMIT: [Analyse & Generate →] button, styled as GOV.UK green button

4. PROGRESS INDICATOR (hidden by default, shown on submit):
   - Step list: ⬜ Step 1: Fetching content... ⬜ Step 2: Analysing...
   - This can be static for now — update to Turbo later if time

Use the admin layout. Tailwind CSS. Clean and simple.
Form should POST to case_type_configs_path with params:
  case_type_config[description], case_type_config[urls][] (array)
```

### E4 Tasks: Applicant Portal

| #   | Task                    | Type        | Owner | Depends On |
| --- | ----------------------- | ----------- | ----- | ---------- |
| 2.8 | Create LookupController | 🤖 AI-first | E4    | 1.3        |

**Prompt:**

```
Create app/controllers/lookup_controller.rb for the public-facing
applicant status portal.

This is a public controller — no authentication, no caseworker context.

#index — render the lookup form (reference number input)

#show — find case by params[:reference] (the case reference string).
  If found: load case with case_notes (only where visible_to_applicant
  is true OR note_type is system), evidences, evidence_requests with
  items. Render status page.
  If not found: redirect to lookup_path with flash error
  "Application not found. Check your reference number and try again."

  Set @status_text — a plain-English status message based on case status:
  - submitted: "Your application has been received"
  - assigned/in_review: "Your application is being reviewed"
  - awaiting_evidence: "We are waiting for some documents"
  - ready_for_decision: "Your application is being considered"
  - decided_approved: "A decision has been made on your application"
  - decided_refused: "A decision has been made on your application"

  Set @visible_notes — case_notes filtered to only show
  applicant-safe entries with applicant_message fallback to content.

Do NOT expose internal data: no caseworker names, no internal notes,
no risk scores, no priority.
```

| #   | Task                                               | Type        | Owner | Depends On |
| --- | -------------------------------------------------- | ----------- | ----- | ---------- |
| 2.9 | Create applicant lookup + status views (Screens 4) | 🤖 AI-first | E4    | 2.8        |

**Prompt:**

```
Read UX_WIREFRAMES.md Screen 4 (Applicant Status Portal) in this project.

Create TWO views:

1. app/views/lookup/index.html.erb — the lookup form
   - GOV.UK styling: "GOV.UK" header, blue bar
   - Heading: "Check the status of your visa application"
   - Hint text: "Enter your application reference number."
   - Text input field labelled "Application reference"
   - [Check status] green button
   - Form GETs to lookup_case_path(reference: input_value)
   - Use a SEPARATE layout: app/views/layouts/public.html.erb
     This layout should look like GOV.UK: white, clean, the GOV.UK
     crown/wordmark at top, very minimal.

2. app/views/lookup/show.html.erb — the status page
   - Application reference and case type shown at top
   - "Current status" box with @status_text and a contextual icon
     (⏳ for waiting, ✅ for decided, 🟠 for action needed)
   - Timeline: list of @visible_notes, most recent first, formatted as:
     ● Date — plain English description
   - "What happens next" info box at the bottom (static text explaining
     the process)
   - NO sensitive information: no caseworker names, no internal status
     codes, no priority

Use the public layout. GOV.UK design language: clean, accessible,
high contrast, black text on white, green buttons.
```

---

## Phase 3: Build Phase 1b — 10:40 to 11:00 (Harden + Progress)

### E1 Tasks: Team Leader Foundation

| #   | Task                        | Type        | Owner | Depends On |
| --- | --------------------------- | ----------- | ----- | ---------- |
| 3.1 | Create DashboardsController | 🤖 AI-first | E1    | 2.1        |

**Prompt:**

```
Create app/controllers/dashboards_controller.rb for team leader and
overview dashboards.

#team — receives team_id or defaults to the first team.
  Load all caseworkers for the team with their cases eager-loaded.
  Calculate:
  - @total_active — all non-decided, non-withdrawn cases across team
  - @overdue_count — cases past SLA
  - @high_risk_count — cases with calculated risk_score > 70
  - @sla_rate — Case.sla_compliance_rate (defined in model)
  - @caseworker_stats — array of hashes:
    { caseworker: record, case_count: N, overdue_count: N,
      capacity: N, utilisation: percentage }
  - @risk_cases — top 10 cases by risk_score desc (overdue +
    approaching SLA)
  - @approaching_sla — cases with SLA deadline in next 7 days
  - @weekly_stats — { new_cases: N, decisions: N,
    avg_processing_days: N, sla_rate: N } for current week

#caseworker — receives caseworker_id.
  Load that caseworker's cases. Same view as cases#index but
  for any caseworker (team leader drilling into someone's caseload).

Use Case.calculate_risk_score and Case.sla_compliance_rate as defined
in DATA_MODEL.md.
```

### E2 Tasks: Interactivity

| #   | Task                                            | Type             | Owner | Depends On |
| --- | ----------------------------------------------- | ---------------- | ----- | ---------- |
| 3.2 | Add "Mark as received" button on evidence items | 🤖🧑 AI-assisted | E2    | 2.5        |

**Prompt:**

```
In the evidence panel partial (app/views/cases/_evidence_panel.html.erb),
add a [Mark as received] button next to each evidence item that has
status :not_received.

The button should be a button_to that PATCHes to
case_evidence_path(case, evidence) with params
evidence: { status: :received, received_at: Time.current }.

Also create app/controllers/evidences_controller.rb with an #update
action that updates the evidence status and redirects back to the
case show page.

Keep it simple — full page reload on click. No Turbo yet.
```

| #   | Task                          | Type             | Owner | Depends On |
| --- | ----------------------------- | ---------------- | ----- | ---------- |
| 3.3 | Add inline note creation form | 🤖🧑 AI-assisted | E2    | 2.5        |

**Prompt:**

```
In the timeline partial (app/views/cases/_timeline.html.erb), add a
simple form at the bottom for adding a new case note.

The form should:
- Have a textarea for content (3 rows)
- Have a checkbox: "Visible to applicant" (default unchecked)
- If checked, show a text field for "Applicant message" (the
  plain-English version they'll see)
- Submit button: [Add note]
- POST to case_notes_path(@case)

Keep it simple. Standard Rails form. Full page reload.
```

### E3 Tasks: Clarifying Questions

| #   | Task                             | Type        | Owner | Depends On |
| --- | -------------------------------- | ----------- | ----- | ---------- |
| 3.4 | Create clarifying questions view | 🤖 AI-first | E3    | 2.6        |

**Prompt:**

```
Read AI_CASE_TYPE_BUILDER.md "Clarifying Questions Screen (Step 2b)"
in this project.

Create app/views/admin/case_type_configs/questions.html.erb

The controller provides @case_type_config with source_metadata containing
a "clarifying_questions" array. Each question has:
- question (string)
- why_it_matters (string)
- options (array of strings)
- confidence (float 0-1)

Render each question as a card:
1. Question number + confidence indicator (🟢 > 0.7, 🟡 0.4-0.7,
   🔴 < 0.4)
2. The question text
3. "Why this matters" in smaller grey text
4. Radio buttons for each suggested option
5. Free-text textarea: "Or describe in your own words"
6. [Skip — use your best judgement] link per question

At the bottom:
- [Continue with answers →] submit button
- [Skip all — generate with defaults] link

Form POSTs to answer_case_type_config_path(@case_type_config)
with params answers: { "0" => "selected option or free text", ... }

Use admin layout. Tailwind CSS.
```

### E4 Tasks: Team Leader Dashboard

| #   | Task                                         | Type        | Owner | Depends On |
| --- | -------------------------------------------- | ----------- | ----- | ---------- |
| 3.5 | Create team leader dashboard view (Screen 3) | 🤖 AI-first | E4    | 3.1        |

**Prompt:**

```
Read UX_WIREFRAMES.md Screen 3 (Team Leader Dashboard) in this project.

Create app/views/dashboards/team.html.erb — the team leader overview.

Requirements matching the wireframe:

1. HEADING: "Team Overview — Visa Processing Unit"

2. STAT CARDS ROW: Four cards:
   - Total active cases: @total_active
   - Overdue: @overdue_count (⚠️ WARNING if > 5)
   - High risk: @high_risk_count (🔴 ALERT if > 0)
   - SLA rate: @sla_rate%

3. CASELOAD BY CASEWORKER:
   - For each caseworker in @caseworker_stats:
     Name | progress bar (case_count / capacity) | "X cases" |
     "⚠️ N OD" if overdue_count > 0
   - Use Tailwind to render progress bars (div with % width bg)
   - Caseworker name is a link to dashboards_caseworker_path(caseworker)
   - Legend: "░░ = capacity remaining   OD = overdue cases"

4. TWO-COLUMN LAYOUT below:

   LEFT: Risk Overview
   - 🔴 High risk (count): list top cases with "Xd overdue"
   - 🟡 Medium risk (count): summary
   - 🟢 Low risk (count)
   - [View all cases →] link

   RIGHT TOP: Cases Approaching SLA
   - @approaching_sla list: ref + "X days left"
   - [View all →] link

   RIGHT BOTTOM: This Week stats
   - New cases, Decisions made, Avg processing days, SLA compliance %

Use Chartkick for the caseload bar chart if it fits naturally,
otherwise Tailwind progress bars are fine.

Case refs should be links to case_path(case).
```

---

## Phase 4: Morning Break — 11:00 to 11:40

| #   | Task                                         | Type     | Owner | Depends On          |
| --- | -------------------------------------------- | -------- | ----- | ------------------- |
| 4.1 | Merge all branches to main                   | 🧑 Human | E1    | All Phase 2+3 tasks |
| 4.2 | 5-min standup: what works, what's blocked    | 🧑 Human | ALL   | 4.1                 |
| 4.3 | Everyone pulls fresh main, verifies app runs | 🧑 Human | ALL   | 4.1                 |
| 4.4 | Fix any merge conflicts or broken views      | 🧑 Human | E1    | 4.1                 |
| 4.5 | Eat a snack                                  | 🧑 Human | ALL   | —                   |

---

## Phase 5: Build Phase 2 — 11:40 to 12:30 (Complete All Journeys)

### E1 Tasks: Integration + Help

| #   | Task                                                         | Type             | Owner | Depends On |
| --- | ------------------------------------------------------------ | ---------------- | ----- | ---------- |
| 5.1 | Fix bugs, verify all data flows, help whoever is behind      | 🧑 Human         | E1    | 4.1        |
| 5.2 | Polish seed data — verify demo cases tell a compelling story | 🤖🧑 AI-assisted | E1    | 5.1        |

**Prompt (if seed data needs tuning):**

```
Review the current db/seeds.rb. Verify that:
1. Priya Sharma's case (VIS-2024-00847) has a timeline matching
   UX_WIREFRAMES.md Screen 2 — notes on 12 Feb, 14 Feb, 01 Mar,
   15 Mar, 28 Mar, 10 Apr
2. The 5 caseworker case counts match: Sarah=12, Fatima=15, David=9,
   Tom=5, Nia=6 (total 47)
3. Overdue cases have SLA deadlines that are clearly past
4. There are at least 2-3 cases in "approaching SLA" state (deadline
   within 7 days)
5. Risk scores calculate correctly (use Case#calculate_risk_score)

Fix any inconsistencies.
```

### E2 Tasks: Caseworker Polish

| #   | Task                               | Type        | Owner | Depends On |
| --- | ---------------------------------- | ----------- | ----- | ---------- |
| 5.3 | Dashboard filters via Turbo Frames | 🤖 AI-first | E2    | 2.4        |

**Prompt:**

```
Update the caseworker dashboard (app/views/cases/index.html.erb) to use
Turbo Frames for filtering.

1. Wrap the filter bar + case table + pagination in a turbo_frame_tag
   "cases_list"
2. Each filter dropdown (status, priority, type) should submit the form
   on change (use Stimulus: data-action="change->filter#submit" or
   just onchange="this.form.requestSubmit()")
3. The form should GET to cases_path with query params
4. The controller already supports filtering — the Turbo Frame just
   makes it not reload the whole page

Also: add a status update dropdown on the case detail page that
PATCHes case status.
```

| #   | Task                                   | Type             | Owner | Depends On |
| --- | -------------------------------------- | ---------------- | ----- | ---------- |
| 5.4 | Add policy citations to evidence panel | 🤖🧑 AI-assisted | E2    | 2.5        |

**Prompt:**

```
Update the evidence panel partial (app/views/cases/_evidence_panel.html.erb).

For each evidence item that has a policy_reference association:
- Show "Required by: [policy_reference.code]" in small grey text
- Show the policy_reference.summary as a one-liner below
- Add a 📋 link to the policy_reference.govuk_url (opens in new tab)

Match the format shown in SEED_DATA_STRATEGY.md under
"Caseworker View — Evidence Panel".
```

### E3 Tasks: Generation + Review

| #   | Task                             | Type        | Owner | Depends On |
| --- | -------------------------------- | ----------- | ----- | ---------- |
| 5.5 | Create review/edit view (Step 4) | 🤖 AI-first | E3    | 2.6        |

**Prompt:**

```
Read AI_CASE_TYPE_BUILDER.md "STEP 4: ADMIN REVIEW & EDIT" in this project.

Create app/views/admin/case_type_configs/review.html.erb — the review
screen for a generated case type configuration.

The controller provides @case_type_config with populated fields:
- name, slug, description, organisation, default_sla_days
- decision_tree_md, state_transitions_md, evidence_requirements_md,
  correspondence_templates_md, risk_scoring_md
- source_metadata (contains the original source text and analysis)

Layout:

1. HEADER: case type name + status badge (draft/published)
   Buttons: [Save Draft] [Publish] at the top-right

2. METADATA SECTION: Editable fields for name, slug, description,
   organisation, default_sla_days

3. FOR EACH MARKDOWN SECTION (decision tree, state transitions,
   evidence, correspondence, risk scoring):

   - Section heading with a collapse/expand toggle
   - TWO-COLUMN layout:
     LEFT: Editable textarea containing the raw markdown
     (8-12 rows, monospace font)
     RIGHT: Rendered markdown preview (use a helper that calls
     Redcarpet to render the markdown to HTML)
   - Below each section: [Regenerate this section] button
     (POSTs to regenerate_case_type_config_path with
     section param)

4. GENERATION LOG: collapsible section at the bottom showing
   CaseTypeGenerationLog entries — step name, model used,
   tokens used, timestamp

Form PATCHes to case_type_config_path.
Use admin layout. Tailwind CSS.

Create a helper method in app/helpers/markdown_helper.rb:
  def render_markdown(text)
    return "" if text.blank?
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true,
      fenced_code_blocks: true)
    markdown = Redcarpet::Markdown.new(renderer,
      fenced_code_blocks: true, tables: true)
    markdown.render(text).html_safe
  end
```

| #   | Task                               | Type        | Owner | Depends On |
| --- | ---------------------------------- | ----------- | ----- | ---------- |
| 5.6 | Create case type config index view | 🤖 AI-first | E3    | 2.6        |

**Prompt:**

```
Create app/views/admin/case_type_configs/index.html.erb — list of all
case type configurations.

Simple table:
- Columns: Name, Organisation, Status (badge), SLA (days),
  Created, Actions
- Status badges: 🟡 Draft | 🟢 Published | ⚪ Archived
- Actions: [View] [Edit] links
- [+ Create New Case Type] button at the top, links to new action

Use admin layout. Tailwind CSS. Clean table styling.
```

### E4 Tasks: Team Dashboard Complete

| #   | Task                              | Type        | Owner | Depends On |
| --- | --------------------------------- | ----------- | ----- | ---------- |
| 5.7 | Create caseworker drill-down view | 🤖 AI-first | E4    | 3.1        |

**Prompt:**

```
Create app/views/dashboards/caseworker.html.erb — the view when a
team leader clicks a caseworker's name on the team dashboard.

It should look like the caseworker's own dashboard (cases/index) but:
- Heading says "Caseload: [Caseworker Name]" instead of the greeting
- Shows all cases for that caseworker, same table format
- Has a "← Back to team dashboard" link at the top
- Read-only — team leader can view but not modify

Reuse the same case table partial if you extracted one, or duplicate
the table markup from cases/index.html.erb.
```

| #   | Task                                                   | Type        | Owner | Depends On |
| --- | ------------------------------------------------------ | ----------- | ----- | ---------- |
| 5.8 | Applicant "action needed" view (Screen 6 — simplified) | 🤖 AI-first | E4    | 2.9        |

**Prompt:**

```
Read UX_WIREFRAMES.md Screen 6 (Applicant Action Required) in this project.

Update app/views/lookup/show.html.erb to handle the case where there are
active evidence requests.

If @case.evidence_requests.sent.any?:
- Change the status box to 🟠 "Action needed — we need documents from you"
- Show a "What you need to provide" section listing each
  EvidenceRequestItem from sent requests:
  - Item name (evidence type in plain English)
  - reason text
  - "How to submit: Upload a copy below" (if digital) or
    "Post to: [address]" (if physical)
  - Status: ❌ Not yet received / ✅ Received
- Deadline prominently displayed
- "What happens if I cannot provide these documents?" info box

Otherwise show the normal passive status.

Use the public layout. All text in plain English — no internal jargon.
```

---

## Phase 6: Lunch — 12:30 to 13:55

| #   | Task                                 | Type     | Owner | Depends On  |
| --- | ------------------------------------ | -------- | ----- | ----------- |
| 6.1 | Merge everything to main             | 🧑 Human | E1    | All Phase 5 |
| 6.2 | Test all 4 demo flows end-to-end     | 🧑 Human | ALL   | 6.1         |
| 6.3 | Identify top 3 bugs + 3 polish items | 🧑 Human | ALL   | 6.2         |
| 6.4 | Eat actual food                      | 🧑 Human | ALL   | —           |

---

## Phase 7: Build Phase 3 — 13:55 to 14:30 (Polish + Wow)

### E1 Tasks: Data + Integration

| #   | Task                         | Type             | Owner | Depends On |
| --- | ---------------------------- | ---------------- | ----- | ---------- |
| 7.1 | Verify + fix seed data story | 🤖🧑 AI-assisted | E1    | 6.1        |

**Prompt:**

```
Load the Rails console and verify the following about the seeded data.
Fix db/seeds.rb if anything is wrong:

1. Case.overdue.count should equal 5 (matching team dashboard:
   Priya + Li Wei + 3 in Fatima's caseload)
2. Case.approaching_sla.count should be >= 3
3. Each caseworker's case count matches: Sarah=12, Fatima=15, David=9,
   Tom=5, Nia=6
4. Priya Sharma's case has 6 evidence items (4 received, 1 not_received,
   1 not_yet_required)
5. Priya's case has 6 timeline entries matching UX_WIREFRAMES.md Screen 2
6. PolicyReference records exist for Skilled Worker, Student, and
   Family visa types
7. Risk scores calculate correctly — Priya should score high (overdue
   + missing evidence + high priority)
```

| #   | Task                                       | Type             | Owner | Depends On |
| --- | ------------------------------------------ | ---------------- | ----- | ---------- |
| 7.2 | Make case refs clickable on team dashboard | 🤖🧑 AI-assisted | E1    | 3.5        |

### E2 Tasks: Visual Polish

| #   | Task                                       | Type        | Owner | Depends On |
| --- | ------------------------------------------ | ----------- | ----- | ---------- |
| 7.3 | Visual polish pass across caseworker views | 🤖 AI-first | E2    | 6.1        |

**Prompt:**

```
Review and polish the caseworker views for visual consistency:

1. app/views/cases/index.html.erb
2. app/views/cases/show.html.erb (and all partials)

Apply these GOV.UK-inspired Tailwind patterns consistently:

- Headings: text-2xl font-bold text-gray-900 (h1), text-xl font-bold (h2)
- Body text: text-gray-700
- Status badges: inline-flex items-center px-2.5 py-0.5 rounded-full
  text-xs font-medium
  - Red: bg-red-100 text-red-800
  - Amber: bg-yellow-100 text-yellow-800
  - Green: bg-green-100 text-green-800
  - Blue: bg-blue-100 text-blue-800
- Cards: bg-white border border-gray-200 rounded-lg p-6
- Tables: divide-y divide-gray-200, hover:bg-gray-50 on rows
- Buttons: GOV.UK green (bg-green-700 hover:bg-green-800 text-white
  font-bold py-2 px-4)
- Links: text-blue-700 hover:underline

Add the morning briefing text at the top of the dashboard:
"Good morning, Sarah. Here's your caseload for today."

Ensure overdue rows have a subtle red-tinted background (bg-red-50).
```

### E3 Tasks: Builder Wow Factor

| #   | Task                                          | Type        | Owner | Depends On |
| --- | --------------------------------------------- | ----------- | ----- | ---------- |
| 7.4 | Add process improvement suggestions (Step 3b) | 🤖 AI-first | E3    | 5.5        |

**Prompt:**

```
Read AI_CASE_TYPE_BUILDER.md "Process Improvement Suggestions Screen
(Step 3b)" in this project.

Add improvement suggestions to the review page.

1. Add a method to CaseTypeGenerator: `suggest_improvements!`
   - Takes the completed config (all markdown fields)
   - Sends to LLM with prompt:
     "Review this case type configuration and suggest improvements based on:
      - GDS service standards (user experience, plain language, self-service)
      - Process efficiency (unnecessary steps, bottlenecks, automation)
      - Risk management (missing escalation, no timeout handling)
      - Fairness (missing appeal routes, no reason given for rejection)

      Return as JSON array of objects with keys: title, current_state,
      recommendation, rationale, impact_description"
   - Store suggestions in source_metadata[:improvement_suggestions]

2. Add a "💡 Suggested Improvements" panel to the review page
   (app/views/admin/case_type_configs/review.html.erb):
   - Render each suggestion as a card with title, current state,
     recommendation, rationale
   - Each card has [Accept & Apply] [Reject] [Defer] buttons
   - Accept sends the suggestion text to the LLM to regenerate the
     affected section
   - Reject/Defer just mark the suggestion status (store in
     source_metadata)

Keep the UX clean — suggestions are clearly optional.
"These are optional recommendations. Accept, reject, or defer each."
```

| #   | Task                             | Type        | Owner | Depends On |
| --- | -------------------------------- | ----------- | ----- | ---------- |
| 7.5 | Pre-cache LLM responses for demo | 🤖 AI-first | E3    | 5.5        |

**Prompt:**

```
Create a fallback mechanism for the AI Case Type Builder so the demo
works even if the LLM API is slow or down.

1. Create db/fixtures/black_bag_exemption.json containing pre-generated
   responses for the Swansea Council black bag limit exemption example:
   - analysis (Step 2 output)
   - clarifying_questions (Step 2b output)
   - generated_config (Step 3 output: decision_tree_md,
     state_transitions_md, evidence_requirements_md,
     correspondence_templates_md, risk_scoring_md)
   - improvement_suggestions (Step 3b output)

   Use the example outputs from AI_CASE_TYPE_BUILDER.md as the
   pre-generated content.

2. Create db/fixtures/motor_caravan_conversion.json with pre-generated
   responses for the DVLA motor caravan example. Use the decision tree
   and evidence from CHALLENGE_3_ANALYSIS.md Part 7.

3. Update LlmClient to accept a `fallback:` keyword argument. If
   `ENV['LLM_USE_FIXTURES'] == 'true'` or if the API call fails,
   load and return the fixture response.

4. Update CaseTypeGenerator to pass the fallback option through.

This ensures the full pipeline UI works even without a live API.
```

### E4 Tasks: Applicant Polish

| #   | Task                           | Type        | Owner | Depends On |
| --- | ------------------------------ | ----------- | ----- | ---------- |
| 7.6 | Applicant portal visual polish | 🤖 AI-first | E4    | 2.9        |

**Prompt:**

```
Polish the applicant-facing views for GOV.UK authenticity:

1. app/views/layouts/public.html.erb — the GOV.UK-style layout:
   - Black header bar with "GOV.UK" in bold white (Transport-style font)
   - Blue divider line below header
   - White content area, max-w-2xl centered
   - Grey footer with standard links text
   - Very clean, very minimal, very GOV.UK

2. app/views/lookup/index.html.erb:
   - Large heading, hint text, single input, one green button
   - Exactly like the real GOV.UK "Check if you need a visa" flow

3. app/views/lookup/show.html.erb:
   - Status box with coloured left border (green for good, amber for
     waiting, red for action needed)
   - Timeline with connected dots (●) and lines (│) between entries
   - "What happens next" in an info box with light blue background
   - All text in plain, accessible English

Use Tailwind only. Match GOV.UK patterns:
https://design-system.service.gov.uk/
```

---

## Phase 8: Feature Freeze — 14:30 to 14:45

| #   | Task                                                                             | Type     | Owner | Depends On  |
| --- | -------------------------------------------------------------------------------- | -------- | ----- | ----------- |
| 8.1 | 🛑 FEATURE FREEZE — merge everything to main                                     | 🧑 Human | E1    | All Phase 7 |
| 8.2 | Test J1: Dashboard → Case Detail → Evidence → Add Note                           | 🧑 Human | E2    | 8.1         |
| 8.3 | Test J2: Applicant lookup → Status page                                          | 🧑 Human | E4    | 8.1         |
| 8.4 | Test J3: Team leader dashboard → Drill into caseworker                           | 🧑 Human | E4    | 8.1         |
| 8.5 | Test J4: Builder → Paste URL → Analyse → Questions → Generate → Review → Publish | 🧑 Human | E3    | 8.1         |
| 8.6 | Test J4 with pre-cached fallback (set LLM_USE_FIXTURES=true)                     | 🧑 Human | E3    | 8.1         |

---

## Phase 9: Final Stretch — 14:45 to 15:30

| #   | Task                                                 | Type     | Owner | Depends On |
| --- | ---------------------------------------------------- | -------- | ----- | ---------- |
| 9.1 | Fix any bugs found in Phase 8 testing                | 🧑 Human | ALL   | 8.1-8.6    |
| 9.2 | Verify Black Bag Exemption demo produces good output | 🧑 Human | E3    | 8.5        |
| 9.3 | Practice demo: caseworker flow                       | 🧑 Human | E2    | 8.2        |
| 9.4 | Practice demo: applicant + team leader flows         | 🧑 Human | E4    | 8.3, 8.4   |
| 9.5 | Practice demo: case type builder                     | 🧑 Human | E3    | 8.5        |
| 9.6 | Practice full 2.5-min walkthrough as a team          | 🧑 Human | ALL   | 9.3-9.5    |
| 9.7 | Agree who says what to judges                        | 🧑 Human | ALL   | 9.6        |
| 9.8 | Everyone can answer the judge Q&A (see PLAN.md)      | 🧑 Human | ALL   | 9.6        |

---

## Quick Reference: Task Counts by Engineer

| Engineer | Total Tasks | AI-first 🤖 | AI-assisted 🤖🧑 | Human 🧑 |
| -------- | ----------- | ----------- | ---------------- | -------- |
| E1       | ~12         | 4           | 3                | 5        |
| E2       | ~10         | 5           | 2                | 3        |
| E3       | ~11         | 7           | 1                | 3        |
| E4       | ~10         | 5           | 1                | 4        |
| ALL      | ~8          | 0           | 0                | 8        |

---

## Emergency Procedures

**If J1 isn't working at T+45 min**: E1 + E2 pair. E3 + E4 continue independently.

**If LLM API dies**: E3 switches to `LLM_USE_FIXTURES=true` immediately. The demo still works. Mention in judging: "production version calls the API live."

**If someone finishes early**: Help E2 polish the caseworker views — that's where the most visual impact is.

**If merge is broken at any break**: E1 drops everything and fixes it. Nobody works on a broken main.
