# Challenge 3: Supporting Casework Decisions — Battle Plan

## 4 Engineers. 3 Hours. First Journey in 45 Minutes.

**Domain**: Visa & Immigration — universally understood, high emotional stakes, relatable to judges.

**Tech Stack** (non-negotiable, agreed before the day):
- **Rails 8 monolith** + Hotwire (Turbo + Stimulus) + Tailwind CSS
- **SQLite** (zero config, portable)
- **Chartkick + Groupdate** (one-liner charts)
- **Auth**: Mocked. Nobody cares about your login page.

---

## Pre-Event Checklist (Night Before)

- [ ] Everyone has Ruby 3.3+, Rails 8+, Git, VS Code + Copilot working
- [ ] Verify `rails new test_app --css tailwind && cd test_app && bin/dev` boots
- [ ] GitHub repo created (or one person ready to do it in 60 seconds)
- [ ] Everyone has read this plan, DATA_MODEL.md, and SEED_DATA_STRATEGY.md
- [ ] Roles assigned (see below)

---

## Role Assignments (4 Engineers)

| Role | Scope | Owns |
|------|-------|------|
| **E1 — Lead / Integrator** | Foundation, data, integration, team leader dashboard | Models, migrations, seeds, routes, controllers, merge gatekeeper |
| **E2 — Caseworker Journey** | Screens 1 + 2 + evidence/actions panels | THE first customer journey. Dashboard, case detail, evidence tracker |
| **E3 — AI Case Type Builder** | The "wow" feature. Dedicated from minute one. | Admin describes process → LLM generates case type config (decision tree, states, evidence, templates) |
| **E4 — Applicant Portal + Team Dashboard** | Screens 3 + 4 + 6 (Lookup, status, team leader) | Public portal, GOV.UK styling, team leader dashboard |

E1 takes team leader dashboard if E4 is behind, but E4 should handle it — it's Chartkick one-liners once the data layer exists.

---

## The Four Journeys

| # | Journey | Screens | Owner | Priority |
|---|---------|---------|-------|----------|
| **J1** | **Caseworker: "What do I need to do today?"** | Dashboard → Case Detail → Evidence/Actions/Timeline | E2 | 🔴 FIRST. Done by T+45 min |
| **J2** | **Applicant: "Where is my application?"** | Lookup → Status page | E4 | 🟡 Done by T+2h |
| **J3** | **Team Leader: "Where's the risk?"** | Team overview → Caseload chart → Drill into cases | E4 | 🟡 Done by T+2h |
| **J4** | **Admin: "Build me a new case type"** | Describe process → LLM analyses → Review generated config → Publish | E3 | 🟡 MVP by T+2h, polished by T+3h |

### Why J4 (AI Case Type Builder) Changes Everything

The caseworker/applicant/team leader journeys prove **the platform works for visa processing**. The Case Type Builder proves **it works for anything**. It's the difference between "we built a visa tool" and "we built a configurable casework engine that any department can adopt in minutes." That's the story that wins.

**The demo moment**: Admin pastes a URL to a Swansea Council black bag exemption page. The system scrapes it, analyses the process, asks 2-3 clarifying questions, then generates a complete case type — decision tree, state machine, evidence requirements, correspondence templates. All in markdown, all editable, all publishable. The judges will lose their minds.

---

## E3's AI Case Type Builder — Detailed Build Plan

### Dependencies
- **LLM API access**: One team member must have OpenAI/Anthropic/etc. API key ready. Sort this the night before. If no API access, use a local model via Ollama or mock the responses with pre-generated outputs for the demo.
- **Data model**: `CaseTypeConfig` + `CaseTypeGenerationLog` tables (E1 generates these with the rest of the migrations)
- **No dependency on the caseworker UI** — E3 works on a completely separate admin namespace

### Pre-Event (Night Before)
- [ ] Confirm LLM API access works (test a simple completion call)
- [ ] Decide: OpenAI `gpt-4o` / Anthropic `claude-sonnet-4` / local Ollama model
- [ ] Add gem: `ruby-openai` or `anthropic` or `langchainrb`
- [ ] Draft the analysis prompt (Step 2 from AI_CASE_TYPE_BUILDER.md) — have it ready as a string constant
- [ ] Draft the generation prompt (Step 3) — same, ready to paste

### E3 Build Timeline

| Phase | Time | Task | Done When |
|-------|------|------|-----------|
| **Pre-build** | 08:30–09:55 | Set up LLM client service class (`app/services/llm_client.rb`). Wire API key via `Rails.application.credentials` or ENV. Test round-trip call works. Write the `CaseTypeConfig` + `CaseTypeGenerationLog` models if E1 hasn't yet. | LLM call returns a response from the app |
| **Phase 1** | 09:55–10:40 | **Admin input screen**: form with description textarea + URL field. `CaseTypeConfigsController#new` + `#create`. On submit: kick off Step 1 (URL scrape via `Nokogiri` or `HTTParty`) + Step 2 (send to LLM for analysis). Store results. | Admin can paste a URL → system scrapes + analyses → stores structured analysis |
| **Phase 1b** | 10:40–11:00 | **Clarifying questions UI** (Step 2b): If LLM flags low-confidence elements, render questions with suggested options. Admin answers → feed back into analysis. Simple form, multiple questions, skip button. | Questions render, answers feed back to enriched analysis |
| **Break** | 11:00–11:40 | Merge. Get feedback from team on what they're seeing. |
| **Phase 2** | 11:40–12:30 | **Generation + Review screen** (Steps 3+4): Send enriched analysis to LLM with generation prompt → get back decision tree, state transitions, evidence table, correspondence templates (all markdown). Render in side-by-side view: source material \| generated output. Each section in an editable textarea with markdown preview. | Admin sees generated config, can edit each section |
| **Lunch** | 12:30–13:55 | Merge. Eat. |
| **Phase 3** | 13:55–14:30 | **Publish flow + Process improvement suggestions** (Step 3b): "Save as Draft" / "Publish" buttons. Published configs appear in a case type list. Add improvement suggestions panel (LLM reviews the process and suggests improvements — accept/reject each). Polish the generation progress UI (✅ Step 1... ✅ Step 2... ⏳ Step 3...). | Full pipeline works end-to-end: input → scrape → analyse → questions → generate → review → publish |
| **Polish** | 14:30–15:00 | Demo prep: ensure the Black Bag Exemption example works perfectly. Pre-cache LLM responses as fallback if API is slow/down during demo. Add the DVLA motor caravan example as a second demo case type. | Two case types generated and publishable for demo |

### Fallback: No LLM API Available on the Day

If API access fails, E3 should have **pre-generated responses** hardcoded as fixtures. The pipeline still runs — it just returns cached output instead of live LLM calls. The UI, the review screen, the edit/publish flow all still work. Mention in the demo: "In production this calls Claude/GPT-4o; for the demo we've pre-generated the outputs to avoid API latency."

### E3 Key Files

```
app/services/llm_client.rb                    # Thin wrapper around LLM API
app/services/case_type_generator.rb            # Orchestrates the 4-step pipeline
app/services/url_scraper.rb                    # Nokogiri scraper for Step 1
app/controllers/admin/case_type_configs_controller.rb
app/views/admin/case_type_configs/new.html.erb        # Input form
app/views/admin/case_type_configs/questions.html.erb   # Clarifying questions
app/views/admin/case_type_configs/review.html.erb      # Side-by-side review
app/views/admin/case_type_configs/index.html.erb       # Published case types
db/migrate/010_create_case_type_configs.rb
db/migrate/011_create_case_type_generation_logs.rb
```

---

## Hour-by-Hour Build Plan

### Pre-Build: 08:30–09:55 (Use Every Minute)

| Time | E1 | E2 | E3 (Builder) | E4 |
|------|----|----|--------------|-----|
| 08:30 | `rails new casework --css tailwind`, push to GitHub | Clone repo, review wireframes | Clone repo. Set up LLM client service class. Test API round-trip. | Clone repo, review applicant + team leader screens |
| 09:00 | Add gems (chartkick, groupdate, ruby-openai/anthropic), generate ALL models + migrations incl. CaseTypeConfig tables | Start GOV.UK-style layout partial (header, nav, footer in Tailwind) | Write `CaseTypeGenerator` service + `UrlScraper` service. Draft analysis prompt as a constant. | Write `db/seeds.rb` from SEED_DATA_STRATEGY.md. Write routes.rb. |
| 09:15 | Confirm Challenge 3. Keep building. | Keep building layout. | Keep building services. | Keep building seeds + routes. |
| 09:45 | Lightning talk — listen, breathe | | | |

**By 09:55**: Rails app boots, all models exist, layout renders. E3 has LLM client working. Seed data may not be complete yet.

### BUILD PHASE 1: T+0 to T+45 min (09:55–10:40) — 🔴 FIRST JOURNEY

**Goal: Sarah opens dashboard → clicks case → sees full case detail. WORKING. WITH REAL DATA.**

| Who | Task | Depends On | Done When |
|-----|------|------------|-----------|
| **E1** | Finish seeds if not done. Run `db:seed`. Verify data. Push `main`. Then: `CasesController#index` + `#show` with scopes (overdue first, status badges) | Models + migrations (done pre-build) | `rails db:seed` produces 47 cases, 5 caseworkers, evidence, notes. Controllers render real data. |
| **E2** | **Screen 1: Caseworker Dashboard** — stat cards + case table + **Screen 2: Case Detail** — summary card, evidence checklist, policy sidebar, "What you need to do", timeline | E1's controller | Click row on dashboard → full case detail with evidence, actions, timeline |
| **E3** | **Admin input screen**: form with description textarea + URL fields. `Admin::CaseTypeConfigsController#new` + `#create`. On submit: scrape URL (Nokogiri) + send to LLM for analysis (Step 1+2). Store structured analysis. | E1's migrations for CaseTypeConfig | Admin pastes URL → system scrapes and analyses → stores result |
| **E4** | **Screen 4: Applicant lookup form** — reference input → `LookupController#show` → status + timeline. Start team leader dashboard layout. | E1's models + seeds | Enter VIS-2024-00847, see status page |

**🎯 T+45 min CHECKPOINT**: J1 works end-to-end. E3 has URL-to-analysis pipeline working.

### BUILD PHASE 1b: T+45 to T+65 min (10:40–11:00) — Harden J1 + Progress All

| Who | Task |
|-----|------|
| **E1** | Start `DashboardsController#team` — team leader stats (total cases, overdue, SLA rate). Help E4 if they need controller support. |
| **E2** | Wire "Mark as received" button on evidence items. Add note form (Turbo Stream inline). |
| **E3** | **Clarifying questions UI** (Step 2b): If LLM flags low-confidence areas, render questions with suggested options. Admin answers or skips. Feed answers back to enriched analysis. |
| **E4** | Applicant status page polish: plain-English status, "What happens next" box. Start **Screen 3: Team Leader Dashboard** — stat cards + Chartkick bar chart (caseload by caseworker). |

### 11:00–11:40 — Morning Break + Lightning Talk

- [ ] **MERGE EVERYTHING TO MAIN. No exceptions.**
- [ ] 5-min standup: what works, what's blocked, what's next
- [ ] Everyone pulls fresh `main` after merge
- [ ] Eat a snack. You'll regret it if you don't.

### BUILD PHASE 2: T+65 to T+115 min (11:40–12:30) — Complete J2 + J3 + Builder MVP

**Goal: All four journeys functional (builder at MVP level).**

| Who | Task | Done When |
|-----|------|-----------|
| **E1** | Integration + bug fixes. Help whoever is most behind. Polish seed data story. If time: add evidence request controller stubs. | All data flows correct, no broken pages |
| **E2** | Case Detail polish: dashboard filters (status/priority/type via Turbo Frames), status update buttons, evidence panel with policy citations | Caseworker can filter, drill down, update status, see policy links |
| **E3** | **Generation + Review screen** (Steps 3+4): Send enriched analysis to LLM → get back decision tree + state transitions + evidence table + correspondence templates (all markdown). Render side-by-side: source \| generated. Editable textareas with markdown preview. Save as Draft / Publish. | Admin sees generated case type config, can edit + publish |
| **E4** | **Screen 3: Team Leader Dashboard** complete — caseload chart, risk overview, approaching-SLA list, weekly stats. Click caseworker name → their cases. | Team leader sees full dashboard, can drill into caseloads |

**🎯 T+115 min CHECKPOINT (12:30)**: Four journeys work:
1. ✅ Caseworker dashboard → case detail → evidence/actions/notes
2. ✅ Applicant lookup → status page
3. ✅ Team leader dashboard → caseload/risk overview → drill to cases
4. ✅ Admin: paste URL → analyse → clarifying questions → generate config → review → publish (may be rough)

### 12:30–13:55 — Lunch + Lightning Talk

- [ ] **MERGE. TEST. EAT.**
- [ ] 15-min working session over lunch: identify top 3 bugs + 3 polish items
- [ ] Assign afternoon tasks

### BUILD PHASE 3: T+115 to T+180 min (13:55–15:00) — Polish + Wow

**First 35 min (13:55–14:30): Polish all journeys + Builder wow factor**

| Who | Task |
|-----|------|
| **E1** | Team leader: risk score display, clickable case refs. Ensure seed data tells a compelling narrative. |
| **E2** | Visual polish across all caseworker views. GOV.UK colour tokens. Status badge consistency. Morning briefing text ("Good morning Sarah. You have 12 cases, 3 need action today.") |
| **E3** | **Process improvement suggestions** (Step 3b): LLM reviews generated config and suggests improvements (add appeal route, add auto-close on timeout, etc.). Accept/reject UI per suggestion. Polish generation progress UI (✅/⏳/⬜ step indicators). Pre-cache fallback responses in case API is slow during demo. |
| **E4** | Applicant portal polish: GOV.UK styling, action-required view when evidence is requested (if evidence request exists in data). Friendly messaging. |

**14:30–14:45: Afternoon Break**

- [ ] 🛑 **FEATURE FREEZE.** Nothing new after this.
- [ ] Full merge to `main`
- [ ] Test ALL FOUR demo flows end-to-end

**14:45–15:30: Final stretch**

| Who | Task |
|-----|------|
| **ALL** | Fix bugs only. No new features. |
| **E1** | Verify seed data + ensure Black Bag Exemption example produces good output |
| **E2** | Practice demo flow: caseworker dashboard → case → evidence → note |
| **E3** | Ensure builder demo works flawlessly with Black Bag Exemption URL. Have DVLA motor caravan as backup example. Pre-cache responses as fallback. |
| **E4** | Practice demo flow: applicant lookup → status. Team leader → risk dashboard. |
| **ALL** | Practice 2-min judge walkthrough. Everyone can give it. |

---

## What Gets Cut (If You're Behind)

Ruthless priority. If you're behind at any checkpoint, cut from the bottom:

| Priority | Feature | Cut? |
|----------|---------|------|
| P0 | Caseworker dashboard + case detail (J1) | NEVER |
| P0 | AI Case Type Builder — input + generate + review (J4) | NEVER. This is the wow. Degrade to pre-cached LLM responses if API issues, but the flow MUST work. |
| P1 | Applicant lookup + status (J2) | NEVER |
| P1 | Team leader dashboard (J3) | NEVER |
| P2 | Builder clarifying questions (Step 2b) | Cut — skip straight to generation |
| P2 | Builder process improvement suggestions (Step 3b) | Cut — generated config is enough |
| P3 | Turbo Frame inline updates | Cut — full page reloads are fine |
| P3 | Dashboard filters | Cut — show all cases |
| P4 | Evidence request form (Screens 5+8) | Cut entirely — not in plan now |
| P4 | Document upload (Screen 7) | Cut entirely — not in plan now |

---

## Demo Script (2.5 minutes, practice it)

**Open 1: The Hook — "Any Government Process in Minutes" (45 sec)**
> "What if any government team could turn their paper process into a digital casework system — without writing code? Watch."
> *Open the Case Type Builder. Paste the Swansea black bag exemption URL.*
> "The system scrapes the page, identifies the process, asks a couple of clarifying questions..."
> *Show the generated decision tree, state transitions, evidence requirements*
> "A complete case configuration — decision tree, workflow states, evidence checklist, correspondence templates — generated from a single URL. An admin reviews it, tweaks anything, and publishes. That department is live."

**Open 2: Caseworker — "Sarah's Morning" (45 sec)**
> "Now the platform in action. Sarah is a visa caseworker. Dashboard: 12 cases, 3 need action, 1 overdue. Two seconds."
> *Click the overdue case (Priya Sharma)*
> "Full picture: evidence arrived and missing, which policy applies, what to do next. All in one view."

**Open 3: Applicant — "Priya Checks Her Status" (20 sec)**
> "Priya enters her reference number and sees where her application stands — plain English, not jargon."
> *Show status page with timeline*

**Open 4: Team Leader — "James Spots the Risk" (20 sec)**
> "James sees Fatima has 15 cases, 3 overdue. Tom has 5. He rebalances before it cascades."
> *Point to workload chart and risk panel*

**Close (10 sec)**
> "Three user journeys and a configurable case engine — built in 3 hours with AI coding tools."

---

## Judge Q&A Prep

| Question | Answer |
|----------|--------|
| "How did you use AI tools?" | "Two layers. First, Copilot built the platform — data model from a markdown spec, all controllers, all views, 47 realistic seed cases. Second, the platform itself uses AI: the Case Type Builder sends process descriptions to an LLM and gets back a complete case configuration. AI building with AI." |
| "What would you do next?" | "Connect published case types to the casework engine so generated configs drive live cases. Add Action Mailer for applicant notifications. Integrate with existing department APIs. Deploy to GOV.UK PaaS. The Case Type Builder means any department can self-onboard — no developer in the loop." |
| "Why this challenge?" | "Caseworkers spend more time finding information than making decisions. But the bigger problem is every department builds bespoke systems for the same patterns. The Case Type Builder makes it a platform play — describe your process, get a casework system." |
| "Tell me about the AI Case Type Builder" | "Admin pastes a URL or describes a process. We scrape the content, send it to an LLM for analysis, ask clarifying questions where confidence is low, then generate a complete config: decision tree, state machine, evidence requirements, correspondence templates. All in editable markdown. Review, tweak, publish. We demoed it with Swansea Council's black bag exemption — a real process, generated from a real GOV.UK page." |
| "What was hardest?" | (Be honest on the day) |

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Merge conflicts | Trunk-based dev, merge every 30 min, E1 is gatekeeper |
| First journey isn't done by T+45 | E1 + E2 pair on J1. E3 + E4 continue independently — they have no J1 dependency. |
| Someone blocked >15 min | Pair up immediately. E1 is the unblocker for E2/E4. E3 is self-sufficient. |
| Demo breaks at judging | Test on `main` only. Feature freeze at 14:30. Always have last-known-good. |
| LLM API down/slow during demo | E3 pre-caches responses for Black Bag + DVLA examples as JSON fixtures. Builder falls back to cached responses silently. Demo still works. |
| LLM API key doesn't work on the day | E3 must verify the night before AND on arrival. If truly dead, hardcode the pipeline to return fixtures. The UI flow still demos perfectly. |
| E3 is isolated and diverges | E3 merges to main at every break. E1 reviews builder code at 11:00 merge. Admin namespace keeps concerns separate. |
| Scope creep | This plan IS the scope. "Is it on the plan?" No? Don't build it. |
| "But what about auth/tests/deploy..." | No. Mock it. Judges want user journeys, not infrastructure. |

---

## Tech Notes

- **Branch strategy**: Trunk-based. Short-lived feature branches. Merge to `main` every 30 min minimum.
- **No JS frameworks**. Hotwire/Turbo handles all interactivity. Stimulus for small client-side behavior only.
- **No API layer**. Server-rendered ERB views. Turbo Frames for partial page updates.
- **Mocked auth**: `Current.caseworker` hardcoded to Sarah Chen (caseworker views) or James Morton (team leader). Switch via URL param or separate routes.
- **File uploads**: Use Active Storage with local disk. Don't overthink it.
- **LLM integration**: `ruby-openai` or `anthropic` gem. API key via ENV var (`OPENAI_API_KEY` / `ANTHROPIC_API_KEY`). Thin `LlmClient` service class that wraps the API. E3 must confirm API works the night before. Have pre-cached responses as fallback — JSON fixtures in `db/fixtures/` for the Black Bag and DVLA examples.
- **Admin namespace**: Case Type Builder lives under `/admin/*`. Separate layout. No overlap with caseworker routes.
- **Markdown rendering**: Use `redcarpet` gem or `CommonMarker` for rendering generated markdown in the review UI. One gem, zero config.
