# AI-Powered Case Type Builder

## The Pitch

> "Admin users describe a business process in plain English — or paste a link to a GOV.UK page — and the system uses an LLM to generate a complete case type configuration: decision tree, state transitions, evidence requirements, and correspondence templates. No code. No developer. Just describe it."

This is the "wow" feature. It turns your casework platform from a visa-processing tool into a **configurable casework engine** that any government department can adopt.

---

## Data Model Extensions

### New Tables

```ruby
# db/migrate/010_create_case_type_configs.rb
class CreateCaseTypeConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :case_type_configs do |t|
      t.string  :name, null: false                    # "Black Bag Limit Exemption"
      t.string  :slug, null: false                    # "black_bag_exemption"
      t.text    :description                          # Human-readable summary
      t.string  :organisation                         # "Swansea Council", "DVLA"
      t.integer :status, default: 0                   # draft, published, archived
      t.integer :default_sla_days                     # 14
      t.text    :decision_tree_md, null: false        # Markdown decision tree (see below)
      t.text    :state_transitions_md, null: false    # Markdown table of state transitions
      t.text    :evidence_requirements_md             # Markdown table of evidence types
      t.text    :correspondence_templates_md          # Markdown templates for letters/emails
      t.text    :risk_scoring_md                      # Markdown risk scoring rules
      t.jsonb   :source_metadata, default: {}         # URLs, descriptions, generation params
      t.references :created_by, foreign_key: { to_table: :caseworkers }
      t.timestamps
    end
    add_index :case_type_configs, :slug, unique: true
  end
end

# db/migrate/011_create_case_type_generation_logs.rb
class CreateCaseTypeGenerationLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :case_type_generation_logs do |t|
      t.references :case_type_config, null: false, foreign_key: true
      t.integer :step, null: false                # 1=scrape, 2=analyse, 3=generate, 4=review
      t.string  :step_name, null: false
      t.text    :input_text                       # What was sent to the LLM
      t.text    :output_text                      # What came back
      t.string  :model_used                       # "gpt-4o", "claude-sonnet-4", etc.
      t.integer :tokens_used
      t.float   :confidence_score                 # LLM self-assessed confidence 0-1
      t.timestamps
    end
  end
end
```

### Why Markdown in the Database?

The decision trees and state transitions are stored as **markdown** — the same format already used throughout this project's analysis docs. This is deliberate:

1. **Human-readable**: Admin users can review and edit directly in a textarea
2. **LLM-native**: LLMs produce and consume markdown fluently — it's their natural output format
3. **Renderable**: Markdown renders beautifully in the UI with zero effort
4. **Diffable**: Changes between versions are easy to compare as text diffs
5. **Parseable**: The engine can parse markdown decision trees and state tables at runtime to drive case workflow

The `source_metadata` JSONB column stores the provenance:

```json
{
  "source_type": "url",
  "urls": [
    "https://www.swansea.gov.uk/article/5075/Apply-for-a-black-bag-limit-exemption"
  ],
  "user_description": null,
  "scraped_content": "If you recycle all accepted kerbside materials...",
  "generation_model": "claude-sonnet-4",
  "generation_timestamp": "2026-04-16T10:30:00Z",
  "generation_prompt_version": "v1.2"
}
```

---

## How It Works — The Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                   ADMIN: CREATE NEW CASE TYPE                    │
│                                                                  │
│  Option A: Paste a description                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ "Residents in Swansea can apply for an exemption to      │   │
│  │  the 3 black bag limit if they have non-recyclable       │   │
│  │  waste like pet litter or nappies. An officer reviews    │   │
│  │  the application. Exemptions last 1 year and waste may   │   │
│  │  be monitored."                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Option B: Provide URL(s) to existing process docs               │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ https://www.swansea.gov.uk/article/5075/Apply-for-a-     │   │
│  │ black-bag-limit-exemption                                │   │
│  │                                                          │   │
│  │ [+ Add another URL]                                      │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Option C: Both — description + reference URLs                   │
│                                                                  │
│  [Analyse & Generate →]                                          │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: SCRAPE & EXTRACT (if URLs provided)                    │
│                                                                  │
│  • Fetch each URL                                                │
│  • Extract main content (strip nav, footer, cookies banners)     │
│  • Follow linked pages 1 level deep (e.g. evidence page,        │
│    eligibility page) to gather the full process                  │
│  • Combine into a single source document                         │
│                                                                  │
│  Output: cleaned text corpus of the business process             │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 2: LLM ANALYSIS — PROCESS IDENTIFICATION                  │
│                                                                  │
│  Prompt: "Given this text describing a government process,       │
│  identify:                                                       │
│  1. The case type name and short description                     │
│  2. Who applies / who is the applicant                           │
│  3. Who decides / who is the caseworker                          │
│  4. What evidence or information is required                     │
│  5. What are the eligibility criteria / decision points          │
│  6. What are the possible outcomes                               │
│  7. What is the typical timeline / SLA                           │
│  8. What communication happens with the applicant                │
│  9. Confidence score (0-1) for each element"                     │
│                                                                  │
│  Output: structured analysis JSON                                │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 2b: CLARIFYING QUESTIONS (if confidence < threshold)       │
│                                                                  │
│  If any element from Step 2 has confidence < 0.6, OR if the     │
│  LLM identifies ambiguities / missing information, it generates  │
│  targeted clarifying questions BEFORE proceeding to generation.  │
│                                                                  │
│  Questions are presented to the admin in the UI. The admin can:  │
│  • Answer the question (free text)                               │
│  • Select from suggested options                                 │
│  • Skip ("I don't know — use your best judgement")               │
│                                                                  │
│  Answers feed back into the analysis, raising confidence and     │
│  filling gaps. The pipeline only proceeds to Step 3 once the     │
│  LLM has sufficient confidence OR the admin explicitly skips.    │
│                                                                  │
│  Output: enriched analysis with admin-confirmed details          │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 3: LLM GENERATION — DECISION TREE + STATE MACHINE         │
│                                                                  │
│  Using the analysis from Step 2, generate:                       │
│                                                                  │
│  A) Decision tree as markdown (matching the project's existing   │
│     format — see examples below)                                 │
│                                                                  │
│  B) State transition table as markdown                           │
│                                                                  │
│  C) Evidence requirements table as markdown                      │
│                                                                  │
│  D) Next-action logic table as markdown                          │
│                                                                  │
│  E) Risk scoring rules as markdown                               │
│                                                                  │
│  F) Correspondence templates as markdown                         │
│                                                                  │
│  Output: complete CaseTypeConfig attributes                      │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 3b: PROCESS IMPROVEMENT SUGGESTIONS                        │
│                                                                  │
│  After generating the config, the LLM reviews the complete       │
│  process against best-practice patterns and suggests             │
│  improvements. These are presented as optional recommendations   │
│  — the admin can accept, reject, or defer each one.              │
│                                                                  │
│  The LLM evaluates against:                                      │
│  • Customer experience best practice (GDS service standards,     │
│    plain language, channel shift, self-service where possible)   │
│  • Business process efficiency (unnecessary steps, bottleneck    │
│    states, missing automation opportunities)                     │
│  • Risk management (missing escalation paths, no timeout         │
│    handling, absent audit trail)                                  │
│  • Compliance & fairness (missing appeal routes, no reason       │
│    given for rejection, no equalities considerations)            │
│  • Operational resilience (single points of failure, no          │
│    handover states, missing SLA breach handling)                 │
│                                                                  │
│  Output: list of improvement suggestions with rationale          │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 4: ADMIN REVIEW & EDIT                                     │
│                                                                  │
│  Present generated config in an editable UI:                     │
│  • Side-by-side: source material | generated output              │
│  • Each section (decision tree, states, evidence) in its own     │
│    editable markdown panel with live preview                     │
│  • Confidence indicators per section (green/amber/red)           │
│  • "Regenerate this section" button per panel                    │
│  • Inline chat: "Make the decision tree stricter on X"           │
│                                                                  │
│  [Save as Draft]  [Publish]                                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Example Output — Black Bag Exemption

Given the Swansea Council URL, the LLM would generate:

### Generated Decision Tree

```markdown
BLACK BAG LIMIT EXEMPTION APPLICATION
│
├─ Is the applicant a Swansea Council resident?
│ ├─ NO → REJECT (not eligible — service area restriction)
│ └─ YES ↓
│
├─ What is the exemption reason?
│ ├─ NAPPIES → Continue ↓
│ ├─ PET LITTER → Continue ↓
│ ├─ PET BEDDING → Continue ↓
│ └─ OTHER / NOT SPECIFIED → REQUEST clarification from applicant
│
├─ Is the applicant currently recycling all accepted kerbside materials?
│ ├─ NO / UNKNOWN → REJECT (precondition not met)
│ │ └─ Correspondence: "You must recycle all accepted materials before
│ │ applying for an exemption. See swansea.gov.uk/recycling"
│ └─ YES ↓
│
├─ Does the applicant produce more than 3 bags of non-recyclable waste?
│ ├─ NO → REJECT (exemption not needed)
│ └─ YES ↓
│
├─ Are there any recyclable materials in the black bags?
│ ├─ YES → REJECT (condition: no recyclable material in any bags)
│ ├─ UNKNOWN → SCHEDULE monitoring visit
│ └─ NO ↓
│
└─ GRANT EXEMPTION
Duration: 1 year from date of approval
Conditions: waste may be monitored; terms and conditions apply
Review date: 12 months from grant
```

### Generated State Transitions

```markdown
| Current State      | Trigger                         | Next State         | Action                              |
| ------------------ | ------------------------------- | ------------------ | ----------------------------------- |
| SUBMITTED          | Application received            | ASSIGNED           | Auto-assign to waste team officer   |
| ASSIGNED           | Officer opens case              | IN_REVIEW          | Begin eligibility checks            |
| IN_REVIEW          | Recycling compliance unclear    | MONITORING         | Schedule monitoring visit           |
| IN_REVIEW          | All checks pass                 | READY_FOR_DECISION | —                                   |
| IN_REVIEW          | Incomplete form                 | AWAITING_INFO      | Request missing info from applicant |
| AWAITING_INFO      | Info received                   | IN_REVIEW          | Resume review                       |
| AWAITING_INFO      | No response 14 days             | CLOSED_NO_RESPONSE | Auto-close                          |
| MONITORING         | Visit confirms compliance       | READY_FOR_DECISION | —                                   |
| MONITORING         | Visit finds recyclables in bags | REJECTED           | Issue rejection notice              |
| READY_FOR_DECISION | Officer approves                | GRANTED            | Issue exemption for 1 year          |
| READY_FOR_DECISION | Officer rejects                 | REJECTED           | Issue rejection notice              |
| GRANTED            | 11 months elapsed               | REVIEW_DUE         | Notify officer: review upcoming     |
| REVIEW_DUE         | Officer reviews + renews        | GRANTED            | Reset 1 year timer                  |
| REVIEW_DUE         | Officer reviews + revokes       | REVOKED            | Issue revocation notice             |
```

### Generated Evidence Requirements

```markdown
| Evidence                                          | Required? | Source           | Verification                      |
| ------------------------------------------------- | --------- | ---------------- | --------------------------------- |
| Name and address                                  | Mandatory | Applicant (form) | Check against council tax records |
| Exemption reason (nappies/pet litter/pet bedding) | Mandatory | Applicant (form) | Self-declared                     |
| Confirmation of kerbside recycling                | Mandatory | Council systems  | Check collection records          |
| Additional information                            | Optional  | Applicant (form) | Officer review                    |
```

---

## Example Output — V5C Vehicle Change

Given the GOV.UK V5C URL (and its linked evidence/how-to pages), the LLM would generate the same structures already present in [CHALLENGE_3_ANALYSIS.md](CHALLENGE_3_ANALYSIS.md) Part 7 — because that's exactly how those were authored. The LLM replicates the same analytical process a human domain expert would follow.

---

## UI Wireframe — Case Type Builder Screen

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏛️  Case Management Service — Admin     James Morton │ Sign out   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Create New Case Type                                              │
│                                                                     │
│  ┌─ Describe the process ────────────────────────────────────────┐ │
│  │                                                                │ │
│  │  Describe the business process in plain English, or paste     │ │
│  │  links to existing documentation. The more detail you         │ │
│  │  provide, the better the generated configuration.             │ │
│  │                                                                │ │
│  │  Description (optional)                                       │ │
│  │  ┌────────────────────────────────────────────────────────┐   │ │
│  │  │ Residents can apply for an exemption to the 3 black    │   │ │
│  │  │ bag limit if they have non-recyclable waste like pet   │   │ │
│  │  │ litter or nappies...                                   │   │ │
│  │  └────────────────────────────────────────────────────────┘   │ │
│  │                                                                │ │
│  │  Reference URLs                                               │ │
│  │  ┌────────────────────────────────────────────────────────┐   │ │
│  │  │ https://www.swansea.gov.uk/article/5075/Apply-for...   │   │ │
│  │  └────────────────────────────────────────────────────────┘   │ │
│  │  [+ Add another URL]                                          │ │
│  │                                                                │ │
│  │  [Analyse & Generate →]                                       │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ Generating... ───────────────────────────────────────────────┐ │
│  │                                                                │ │
│  │  ✅ Step 1: Fetching & extracting content from URLs           │ │
│  │  ✅ Step 2: Analysing business process                        │ │
│  │  � Step 2b: Clarifying questions (3 questions)               │ │
│  │  ⬜ Step 3: Generating decision tree & state transitions      │ │
│  │  ⬜ Step 3b: Reviewing for process improvements               │ │
│  │  ⬜ Step 4: Ready for review                                  │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### Clarifying Questions Screen (Step 2b)

When the LLM can't confidently infer part of the process, it asks before guessing. The questions are specific, contextual, and offer suggested answers where possible.

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏛️  Case Management Service — Admin     James Morton │ Sign out   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Create New Case Type — Clarifying Questions                       │
│                                                                     │
│  I've analysed the source material and need a few details to       │
│  generate an accurate case configuration.                          │
│                                                                     │
│  ┌─ Question 1 of 3 ──────────────────────── Confidence: 🟡 0.4 ─┐│
│  │                                                                ││
│  │  What happens if the applicant doesn't respond to a request   ││
│  │  for more information?                                         ││
│  │                                                                ││
│  │  The source material doesn't describe a timeout or             ││
│  │  non-response handling process.                                ││
│  │                                                                ││
│  │  Suggested options:                                            ││
│  │  ○ Close the case after 14 days with no response              ││
│  │  ○ Close the case after 28 days with no response              ││
│  │  ○ Send a reminder after 7 days, then close after 14          ││
│  │  ○ Keep the case open indefinitely                            ││
│  │                                                                ││
│  │  Or describe in your own words:                                ││
│  │  ┌────────────────────────────────────────────────────────┐   ││
│  │  │                                                        │   ││
│  │  └────────────────────────────────────────────────────────┘   ││
│  │                                                                ││
│  │  [Skip — use your best judgement]                              ││
│  │                                                                ││
│  └────────────────────────────────────────────────────────────────┘│
│                                                                     │
│  ┌─ Question 2 of 3 ──────────────────────── Confidence: 🟡 0.3 ─┐│
│  │                                                                ││
│  │  Can applicants appeal a rejected exemption?                   ││
│  │                                                                ││
│  │  The source page doesn't mention an appeal or review process.  ││
│  │  Most council services have some form of reconsideration.      ││
│  │                                                                ││
│  │  Suggested options:                                            ││
│  │  ○ Yes — formal appeal to a senior officer                    ││
│  │  ○ Yes — informal reconsideration by the same team            ││
│  │  ○ No appeal route                                            ││
│  │                                                                ││
│  │  Or describe in your own words:                                ││
│  │  ┌────────────────────────────────────────────────────────┐   ││
│  │  │                                                        │   ││
│  │  └────────────────────────────────────────────────────────┘   ││
│  │                                                                ││
│  │  [Skip — use your best judgement]                              ││
│  │                                                                ││
│  └────────────────────────────────────────────────────────────────┘│
│                                                                     │
│  ┌─ Question 3 of 3 ──────────────────────── Confidence: 🟡 0.5 ─┐│
│  │                                                                ││
│  │  Who should be notified when an exemption is granted?          ││
│  │                                                                ││
│  │  The collection team likely needs to know about new exemptions ││
│  │  so they accept extra bags. Is this automated or manual?       ││
│  │                                                                ││
│  │  Suggested options:                                            ││
│  │  ○ Auto-notify the collection team by email                   ││
│  │  ○ Collection team checks a shared list/dashboard             ││
│  │  ○ Caseworker manually tells the collection team              ││
│  │                                                                ││
│  │  Or describe in your own words:                                ││
│  │  ┌────────────────────────────────────────────────────────┐   ││
│  │  │                                                        │   ││
│  │  └────────────────────────────────────────────────────────┘   ││
│  │                                                                ││
│  │  [Skip — use your best judgement]                              ││
│  │                                                                ││
│  └────────────────────────────────────────────────────────────────┘│
│                                                                     │
│  [Continue with answers →]  [Skip all — generate with defaults]    │
└─────────────────────────────────────────────────────────────────────┘
```

#### What Triggers Questions

The LLM asks when it detects:

| Gap Type                                  | Example                                                          | Why It Matters                                                    |
| ----------------------------------------- | ---------------------------------------------------------------- | ----------------------------------------------------------------- |
| **Missing timeout/non-response handling** | "What if the applicant never replies?"                           | Every casework process needs a dead-end escape                    |
| **No appeal or reconsideration route**    | "Can a rejected applicant challenge the decision?"               | Fairness requirement in public services                           |
| **Ambiguous eligibility boundary**        | "Does 'resident' mean council tax payer, or anyone in the area?" | Decision tree can't branch without a clear test                   |
| **Unclear role/responsibility**           | "Who does the monitoring visit — same team or a different one?"  | State transitions need to know who acts                           |
| **Missing downstream notification**       | "Who needs to know when the outcome is decided?"                 | Incomplete process if the decision doesn't reach the right people |
| **Unclear evidence standard**             | "What counts as proof of recycling compliance?"                  | Evidence checklist needs specifics                                |
| **SLA not stated**                        | "How quickly should this be processed?"                          | Can't calculate risk or overdue status without a target           |
| **Volume/frequency unknown**              | "How many of these do you handle per week?"                      | Affects risk scoring and capacity planning                        |

#### Question Generation Prompt

```
Given the analysis of this business process, identify aspects where:
1. The source material is silent or ambiguous
2. A casework system would need a definitive answer to function correctly
3. The confidence score for any element is below 0.6

For each gap, generate a clarifying question with:
- The question in plain English
- Why it matters (1 sentence)
- 2-4 suggested multiple-choice options (based on common government process patterns)
- A free-text option for the admin to describe their own answer

Prioritise questions that would most change the generated decision tree or state
transitions. Maximum 5 questions — do not ask about minor details.
```

### Process Improvement Suggestions Screen (Step 3b)

After generating the config, the LLM reviews the complete process and proposes improvements. These appear as a panel alongside the generated config — clearly marked as suggestions, not mandated changes.

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏛️  Case Management Service — Admin     James Morton │ Sign out   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Review: Black Bag Limit Exemption          [Save Draft] [Publish] │
│                                                                     │
│  ┌─ 💡 Suggested Improvements (4) ──────────────────────────────┐ │
│  │                                                                │ │
│  │  These are optional recommendations based on government        │ │
│  │  service design best practice. Accept, reject, or defer each. │ │
│  │                                                                │ │
│  │  ┌─ 1. Add applicant self-service status tracking ──────────┐ │ │
│  │  │                                                           │ │ │
│  │  │  Currently: applicant submits and waits with no           │ │ │
│  │  │  visibility of progress.                                  │ │ │
│  │  │                                                           │ │ │
│  │  │  Recommendation: give applicants a reference number and   │ │ │
│  │  │  a status page showing where their application is.        │ │ │
│  │  │  GDS Service Standard #5: "Make sure users can get        │ │ │
│  │  │  through the end-to-end journey unaided."                 │ │ │
│  │  │                                                           │ │ │
│  │  │  Impact: adds APPLICANT_NOTIFIED action on each state     │ │ │
│  │  │  transition + applicant-facing status descriptions.       │ │ │
│  │  │                                                           │ │ │
│  │  │  [Accept & Apply]  [Reject]  [Defer for later]            │ │ │
│  │  └───────────────────────────────────────────────────────────┘ │ │
│  │                                                                │ │
│  │  ┌─ 2. Auto-close stale cases ─────────────────────────────┐ │ │
│  │  │                                                           │ │ │
│  │  │  Currently: if the applicant doesn't respond to an info   │ │ │
│  │  │  request, the case sits in AWAITING_INFO indefinitely.    │ │ │
│  │  │                                                           │ │ │
│  │  │  Recommendation: add a 14-day timeout with an automated   │ │ │
│  │  │  reminder at 7 days, then auto-close with a notification  │ │ │
│  │  │  to the applicant explaining they can reapply.            │ │ │
│  │  │                                                           │ │ │
│  │  │  Impact: adds 2 state transitions + reminder action +     │ │ │
│  │  │  auto-close correspondence template.                      │ │ │
│  │  │                                                           │ │ │
│  │  │  [Accept & Apply]  [Reject]  [Defer for later]            │ │ │
│  │  └───────────────────────────────────────────────────────────┘ │ │
│  │                                                                │ │
│  │  ┌─ 3. Add rejection reason to correspondence ──────────────┐ │ │
│  │  │                                                           │ │ │
│  │  │  Currently: the rejection notice doesn't specify which    │ │ │
│  │  │  criterion failed.                                        │ │ │
│  │  │                                                           │ │ │
│  │  │  Recommendation: include the specific reason in the       │ │ │
│  │  │  rejection letter (e.g. "recyclable material found in     │ │ │
│  │  │  bags" vs "not a Swansea resident"). Citizens who         │ │ │
│  │  │  understand why they were rejected are less likely to     │ │ │
│  │  │  submit repeat applications or complaints.                │ │ │
│  │  │                                                           │ │ │
│  │  │  Impact: updates correspondence template with             │ │ │
│  │  │  per-rejection-reason variant text.                       │ │ │
│  │  │                                                           │ │ │
│  │  │  [Accept & Apply]  [Reject]  [Defer for later]            │ │ │
│  │  └───────────────────────────────────────────────────────────┘ │ │
│  │                                                                │ │
│  │  ┌─ 4. Consider equalities monitoring ──────────────────────┐ │ │
│  │  │                                                           │ │ │
│  │  │  Currently: no demographic data is collected.             │ │ │
│  │  │                                                           │ │ │
│  │  │  Recommendation: offer optional equalities monitoring     │ │ │
│  │  │  at application stage (not used in decision). Enables     │ │ │
│  │  │  the council to check whether the exemption process is    │ │ │
│  │  │  disproportionately affecting protected groups.           │ │ │
│  │  │  Public Sector Equality Duty (Equality Act 2010 s.149).  │ │ │
│  │  │                                                           │ │ │
│  │  │  Impact: adds optional evidence fields; no decision       │ │ │
│  │  │  tree changes.                                            │ │ │
│  │  │                                                           │ │ │
│  │  │  [Accept & Apply]  [Reject]  [Defer for later]            │ │ │
│  │  └───────────────────────────────────────────────────────────┘ │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ Tabs ────────────────────────────────────────────────────────┐ │
│  │ [Decision Tree] [States] [Evidence] [Actions] [Correspondence]│ │
│  └────────────────────────────────────────────────────────────────┘ │
```

#### Improvement Categories & Evaluation Criteria

The LLM evaluates the generated process against these lenses:

| Category                   | What It Checks                                                                                       | Example Suggestions                                                                |
| -------------------------- | ---------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **Customer experience**    | Can the user self-serve? Do they get confirmation? Do they know what's happening? Is language plain? | Add status tracking; add confirmation email; simplify rejection wording            |
| **Process efficiency**     | Are there unnecessary manual steps? Could anything be automated? Are there bottleneck states?        | Auto-approve trivial cases; batch-process similar applications; add auto-reminders |
| **Completeness**           | Are all paths handled? What about edge cases, timeouts, re-submissions?                              | Add non-response timeout; handle duplicate applications; add resubmission path     |
| **Fairness & compliance**  | Is there an appeal route? Are reasons given for refusal? Equalities considerations? Data retention?  | Add appeal/reconsideration; include rejection reasons; add equalities monitoring   |
| **Operational visibility** | Can managers see workload? Are SLAs tracked? Are there alerts for problems?                          | Add team dashboard metrics; add SLA breach escalation; add volume reporting        |
| **Risk management**        | What could go wrong? Missing escalation paths? No fraud checks?                                      | Add escalation for disputed cases; add duplicate-applicant check; add audit log    |

#### Improvement Generation Prompt

```
You have just generated a complete case type configuration for a government
service. Now review the configuration critically as a government service design
consultant. Consider:

1. GDS Service Standard (https://www.gov.uk/service-manual/service-standard)
2. Government business process best practice
3. Citizen experience — transparency, fairness, accessibility
4. Operational efficiency — automation, bottleneck avoidance
5. Legal/compliance — Equality Act 2010, data protection, appeals rights

For each suggestion:
- State the current gap (what's missing or suboptimal)
- Explain the recommendation in plain English
- Cite the relevant standard or best practice
- Describe the specific impact on the configuration (which sections change)
- Rate the priority: HIGH (process is broken without this), MEDIUM (significantly
  better with it), LOW (nice-to-have polish)

Return 3-6 suggestions, ordered by priority. Do not suggest changes that are
already present in the configuration.
```

#### "Accept & Apply" Mechanics

When the admin clicks **Accept & Apply** on a suggestion, the system:

1. Sends the current config + the specific suggestion back to the LLM
2. LLM generates the precise markdown changes (same as the refinement pipeline)
3. Changes are shown as a diff for confirmation
4. On confirmation, applied and logged as a version with `change_description: "Applied suggestion: Add applicant self-service status tracking"`

**Defer** saves the suggestion to a backlog visible on the case type config page. The admin can return to deferred suggestions at any time — including after the case type is published and in use.

```ruby
# db/migrate/013_create_case_type_suggestions.rb
class CreateCaseTypeSuggestions < ActiveRecord::Migration[8.0]
  def change
    create_table :case_type_suggestions do |t|
      t.references :case_type_config, null: false, foreign_key: true
      t.string  :title, null: false
      t.text    :description, null: false
      t.string  :category                    # customer_experience, efficiency, compliance, etc.
      t.integer :priority, default: 1        # 0=low, 1=medium, 2=high
      t.text    :impact_description          # which config sections would change
      t.string  :standard_reference          # "GDS Service Standard #5"
      t.integer :status, default: 0          # suggested, accepted, rejected, deferred
      t.references :resolved_by, foreign_key: { to_table: :caseworkers }
      t.datetime :resolved_at
      t.timestamps
    end
  end
end
```

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏛️  Case Management Service — Admin     James Morton │ Sign out   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Review: Black Bag Limit Exemption          [Save Draft] [Publish] │
│                                                                     │
│  Organisation: Swansea Council                                     │
│  Default SLA: 14 days                                              │
│  Source: swansea.gov.uk/article/5075   Confidence: 🟢 High (0.87) │
│                                                                     │
│  ┌─ Tabs ────────────────────────────────────────────────────────┐ │
│  │ [Decision Tree] [States] [Evidence] [Actions] [Correspondence]│ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ Decision Tree ──────────────────────── Confidence: 🟢 0.91 ─┐ │
│  │                                                    [Regenerate]│ │
│  │  ┌─ Edit (Markdown) ──────┐  ┌─ Preview ────────────────────┐│ │
│  │  │ BLACK BAG LIMIT...     │  │  ┌── BLACK BAG LIMIT...      ││ │
│  │  │ │                      │  │  │                            ││ │
│  │  │ ├─ Is the applicant... │  │  ├─ Is the applicant a       ││ │
│  │  │ │   ├─ NO → REJECT     │  │  │   Swansea resident?       ││ │
│  │  │ │   └─ YES ↓           │  │  │   ├─ NO → REJECT          ││ │
│  │  │                        │  │  │   └─ YES ↓                 ││ │
│  │  │ [full editable md]     │  │  │                            ││ │
│  │  └────────────────────────┘  └───────────────────────────────┘│ │
│  │                                                                │ │
│  │  💬 Refine: ┌──────────────────────────────────────────────┐  │ │
│  │             │ "Add a check for whether the applicant has   │  │ │
│  │             │  received a previous exemption"              │  │ │
│  │             └──────────────────────────────────────────────┘  │ │
│  │             [Apply refinement]                                 │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ Source Material ─────────────────────────────────────────────┐ │
│  │  Scraped from: swansea.gov.uk/article/5075                    │ │
│  │  "If you recycle all accepted kerbside materials and still    │ │
│  │   produce more than three black bags of non-recyclable waste  │ │
│  │   then you can apply for an exemption..."                     │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Post-Creation Editing — Natural Language Refinement

Case types are living configurations. After initial generation, admin users refine them over time using **conversational natural language instructions** — no need to hand-edit markdown or understand the tree syntax.

### How It Works

The admin opens a published (or draft) case type and uses a chat panel to describe changes in plain English. The LLM receives the current config sections as context, interprets the instruction, and produces a targeted diff.

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏛️  Case Management Service — Admin     James Morton │ Sign out   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Edit: Black Bag Limit Exemption (Published)    [Revision History] │
│                                                                     │
│  ┌─ Chat ────────────────────────────────────────────────────────┐ │
│  │                                                                │ │
│  │  You: "I'd like to be able to escalate the case to a more    │ │
│  │        senior manager"                                        │ │
│  │                                                                │ │
│  │  System: I'll add an escalation path. Here's what I'd change: │ │
│  │                                                                │ │
│  │  Decision Tree — 1 addition:                                  │ │
│  │  + New branch after READY_FOR_DECISION: "Is case complex      │ │
│  │    or disputed? → YES → ESCALATE to senior manager"           │ │
│  │                                                                │ │
│  │  State Transitions — 2 additions:                             │ │
│  │  + READY_FOR_DECISION | Officer escalates | ESCALATED |       │ │
│  │    Assign to senior waste services manager                    │ │
│  │  + ESCALATED | Senior manager decides | GRANTED or REJECTED | │ │
│  │    Record decision with escalation rationale                  │ │
│  │                                                                │ │
│  │  Actions — 1 addition:                                        │ │
│  │  + New action type: ESCALATE_TO_SENIOR (priority HIGH)        │ │
│  │                                                                │ │
│  │  [Apply Changes]  [Show Full Diff]  [Reject]                  │ │
│  │                                                                │ │
│  │  ─────────────────────────────────────────────────────────    │ │
│  │                                                                │ │
│  │  You: "Email recyclingteam@swansea.gov.uk each time a case   │ │
│  │        is completed"                                          │ │
│  │                                                                │ │
│  │  System: I'll add a notification trigger. Changes:            │ │
│  │                                                                │ │
│  │  State Transitions — 2 modifications:                         │ │
│  │  ~ READY_FOR_DECISION | Officer approves | GRANTED |          │ │
│  │    Issue exemption for 1 year;                                │ │
│  │    Email recyclingteam@swansea.gov.uk with case summary       │ │
│  │  ~ READY_FOR_DECISION | Officer rejects | REJECTED |          │ │
│  │    Issue rejection notice;                                    │ │
│  │    Email recyclingteam@swansea.gov.uk with case summary       │ │
│  │                                                                │ │
│  │  Correspondence Templates — 1 addition:                       │ │
│  │  + "Case Completed — Team Notification" template              │ │
│  │    To: recyclingteam@swansea.gov.uk                           │ │
│  │    Subject: "Case {{reference}} — {{outcome}}"                │ │
│  │    Body: summary of case, decision, officer, date             │ │
│  │                                                                │ │
│  │  [Apply Changes]  [Show Full Diff]  [Reject]                  │ │
│  │                                                                │ │
│  │  ─────────────────────────────────────────────────────────    │ │
│  │                                                                │ │
│  │  ┌────────────────────────────────────────────────────────┐   │ │
│  │  │ Describe a change in plain English...                  │   │ │
│  │  └────────────────────────────────────────────────────────┘   │ │
│  │  [Send]                                                       │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ Live Preview (updates after each applied change) ────────────┐ │
│  │                                                                │ │
│  │  [Decision Tree] [States] [Evidence] [Actions] [Correspondence]│ │
│  │                                                                │ │
│  │  (rendered markdown with changes highlighted in green/red)     │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  Unsaved changes: 2          [Save as Draft]  [Publish New Version]│
└─────────────────────────────────────────────────────────────────────┘
```

### The Refinement Pipeline

```
User instruction (natural language)
        │
        ▼
┌───────────────────────────────────────────────────┐
│  LLM REFINEMENT PROMPT                            │
│                                                    │
│  Context provided:                                 │
│  • Current decision_tree_md                        │
│  • Current state_transitions_md                    │
│  • Current evidence_requirements_md                │
│  • Current correspondence_templates_md             │
│  • Current risk_scoring_md                         │
│  • Change history (previous refinements)           │
│                                                    │
│  Instruction:                                      │
│  "Given the current case type configuration above, │
│   apply the following change requested by an admin  │
│   user. Return ONLY the sections that change, in   │
│   the same markdown format, with a brief summary   │
│   of what was modified and which sections were      │
│   affected."                                       │
│                                                    │
│  User says: "{instruction}"                        │
│                                                    │
│  Output format:                                    │
│  - affected_sections: [list]                       │
│  - summary: "human-readable description of change" │
│  - changes: { section_name: new_markdown }         │
│  - confidence: 0.0-1.0                             │
└──────────────────┬────────────────────────────────┘
                   │
                   ▼
        Admin reviews diff
                   │
           ┌───────┴───────┐
        Accept           Reject
           │               │
     Apply changes    Log & discard
     + version bump
     + generation log entry
```

### What Kinds of Instructions Work

The LLM interprets a wide range of natural language refinements. Examples:

| User Says                                                                      | Sections Affected                              | What Changes                                                      |
| ------------------------------------------------------------------------------ | ---------------------------------------------- | ----------------------------------------------------------------- |
| "I'd like to be able to escalate the case to a more senior manager"            | Decision tree, State transitions, Actions      | New ESCALATED state, escalation branch in tree, new action type   |
| "Email recyclingteam@swansea.gov.uk each time a case is completed"             | State transitions, Correspondence templates    | Notification action on terminal states, new email template        |
| "Add a check for whether they've had an exemption before"                      | Decision tree, Evidence requirements           | New decision node, new evidence type (previous exemption history) |
| "Extend the SLA from 14 days to 21 days"                                       | Config metadata                                | `default_sla_days` updated                                        |
| "If the applicant doesn't respond within 7 days instead of 14, close the case" | State transitions                              | Timeout trigger changed from 14 → 7 days                          |
| "Add a monitoring visit after approval for the first 3 months"                 | State transitions, Actions                     | New POST_GRANT_MONITORING state, scheduled visit action           |
| "Remove the pet bedding option — we don't accept that anymore"                 | Decision tree, Evidence requirements           | Remove branch, update valid exemption reasons                     |
| "Make the rejection letter friendlier and include links to recycling info"     | Correspondence templates                       | Tone/content update to rejection template                         |
| "High-risk cases should go straight to a senior officer"                       | Decision tree, Risk scoring, State transitions | Conditional routing based on risk score                           |

### Versioning & Audit

Every applied refinement creates a version. Admins can view history and roll back.

```ruby
# db/migrate/012_create_case_type_config_versions.rb
class CreateCaseTypeConfigVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :case_type_config_versions do |t|
      t.references :case_type_config, null: false, foreign_key: true
      t.integer    :version_number, null: false
      t.text       :decision_tree_md
      t.text       :state_transitions_md
      t.text       :evidence_requirements_md
      t.text       :correspondence_templates_md
      t.text       :risk_scoring_md
      t.text       :change_description              # "Added escalation path to senior manager"
      t.text       :user_instruction                 # The original natural language input
      t.references :changed_by, foreign_key: { to_table: :caseworkers }
      t.timestamps
    end
    add_index :case_type_config_versions, [:case_type_config_id, :version_number], unique: true,
              name: "idx_config_versions_unique"
  end
end
```

```ruby
# app/models/case_type_config.rb (additions)
class CaseTypeConfig < ApplicationRecord
  has_many :versions, class_name: "CaseTypeConfigVersion", dependent: :destroy

  def apply_refinement!(instruction:, changes:, changed_by:)
    transaction do
      # Snapshot current state before applying
      versions.create!(
        version_number: (versions.maximum(:version_number) || 0) + 1,
        decision_tree_md: decision_tree_md,
        state_transitions_md: state_transitions_md,
        evidence_requirements_md: evidence_requirements_md,
        correspondence_templates_md: correspondence_templates_md,
        risk_scoring_md: risk_scoring_md,
        change_description: changes[:summary],
        user_instruction: instruction,
        changed_by: changed_by
      )

      # Apply the LLM-generated changes
      update!(changes.except(:summary, :affected_sections, :confidence))
    end
  end

  def rollback_to!(version_number)
    version = versions.find_by!(version_number: version_number)
    update!(
      decision_tree_md: version.decision_tree_md,
      state_transitions_md: version.state_transitions_md,
      evidence_requirements_md: version.evidence_requirements_md,
      correspondence_templates_md: version.correspondence_templates_md,
      risk_scoring_md: version.risk_scoring_md
    )
  end
end
```

### Safety: Published Config Protection

Editing a published case type creates a **draft revision**. It does not modify live cases until the admin explicitly publishes the new version. Active cases continue running against the version they were created with.

```ruby
# app/models/case.rb (addition)
class Case < ApplicationRecord
  belongs_to :case_type_config, optional: true
  # Stores the version_number at time of case creation —
  # case runs against this version even if config is updated later
  # column: case_type_config_version_number (integer)
end
```

---

## Runtime: How the Engine Uses the Config

Once published, a `CaseTypeConfig` drives the casework engine:

1. **New case created** → Engine reads `state_transitions_md`, sets initial state
2. **Evidence checklist** → Parsed from `evidence_requirements_md`, rendered on case detail page
3. **"What you need to do"** → Engine walks `decision_tree_md` against current case data to determine next action
4. **Risk scoring** → Parsed from `risk_scoring_md`, calculated on case update
5. **Correspondence** → Templates from `correspondence_templates_md` pre-filled with case data

The markdown is **parsed at runtime** into executable logic. A simple parser walks the decision tree nodes (`├─`, `└─`, `→`) and evaluates conditions against case attributes. State transition tables are parsed into `{from_state, trigger, to_state, action}` tuples.

```ruby
# app/services/decision_tree_evaluator.rb
class DecisionTreeEvaluator
  def initialize(case_type_config)
    @tree = MarkdownTreeParser.parse(case_type_config.decision_tree_md)
  end

  def evaluate(kase)
    @tree.walk do |node|
      if node.condition?
        result = CaseConditionMatcher.match(node.condition, kase)
        node.branch(result)
      elsif node.outcome?
        return node.outcome  # :grant, :refuse, :request_evidence, :escalate
      end
    end
  end
end
```

---

## Why This Is the "AI" Feature That Wins

1. **Non-technical users** can configure case types — no developer needed
2. **LLM does the hard work** — extracting structure from unstructured gov guidance
3. **Human stays in the loop** — review, edit, refine before publishing
4. **Provenance is tracked** — every generation step is logged with model, confidence, input/output
5. **Markdown is the contract** — readable by humans, parseable by machines, editable by both
6. **It's demo-able in 2 minutes**: paste a URL → watch it generate → show the decision tree → create a case

---

## Mock Implementation Strategy (for the hackathon)

Since the event doesn't provide LLM API access:

1. **Pre-generate** configs for 2-3 case types using your own LLM access:
   - Swansea black bag exemption (simple, local authority)
   - DVLA V5C vehicle change (complex, already documented)
   - One visa type (already in the codebase)

2. **Mock the generation pipeline** with a 3-second delay + pre-stored results — the UI shows the progress steps animating, then reveals the pre-generated config

3. **Make the review/edit screen fully functional** — this is the part judges will interact with

4. **If you have BYO API access**, wire it up live for the demo. If not, the mock is convincing enough.

---

## Routes

```ruby
# config/routes.rb (additions)
namespace :admin do
  resources :case_type_configs do
    post :generate, on: :collection     # trigger LLM pipeline from URL/description
    post :answer_questions, on: :member  # submit clarifying question answers (Step 2b)
    post :regenerate_section, on: :member # regenerate one section from scratch
    post :refine, on: :member            # natural language refinement (chat)
    post :publish, on: :member
    post :archive, on: :member
    resources :versions, only: [:index, :show], controller: "case_type_config_versions" do
      post :rollback, on: :member        # revert to a previous version
    end
    resources :suggestions, only: [:index], controller: "case_type_suggestions" do
      post :accept, on: :member          # apply a suggestion
      post :reject, on: :member
      post :defer, on: :member
    end
  end
end
```

---

## Model

```ruby
# app/models/case_type_config.rb
class CaseTypeConfig < ApplicationRecord
  belongs_to :created_by, class_name: "Caseworker"
  has_many :generation_logs, class_name: "CaseTypeGenerationLog"

  enum :status, { draft: 0, published: 1, archived: 2 }

  validates :name, :slug, :decision_tree_md, :state_transitions_md, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9_]+\z/ }

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    self.slug ||= name&.parameterize(separator: "_")
  end
end
```
