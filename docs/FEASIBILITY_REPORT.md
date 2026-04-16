# Feasibility Report: AI Engineering Lab Hackathon

## Key Constraints

- **Actual build time**: ~5 hours (09:55–15:30 minus breaks/talks ≈ 4h 40m realistically)
- **Team**: 5 experienced engineers with AI coding tools
- **No AI model APIs provided** — must mock, BYO, or run locally
- **Must demo** a working prototype with a complete user journey
- **Scoring**: Milestone points (live, throughout day) + judge rubric (what you built, AI tool usage, what's next)

---

## Challenge 1: From PDF to Digital Service

### What it is
Replace a PDF-based government form process with a digital service — citizen submission, confirmation, status tracking, caseworker processing.

### Feasibility: ★★★★★ (Very High)

**Pros:**
- Extremely well-scoped. Two clear user personas (citizen, caseworker). Two clear UIs.
- The document literally calls it "a good starting point" — it's the easiest challenge by design.
- No AI model dependency. The value is in the service, not in AI inference.
- Fast to prototype: form builder, submission flow, status page, caseworker queue. Standard CRUD.
- Easy to hit milestones early — repo, first prototype, complete journey are all straightforward.
- AI coding tools shine here — generating form components, validation logic, API routes, database schemas at speed.

**Cons:**
- **Every team that wants a safe option will pick this.** High competition for the same challenge.
- Judges have explicitly said this is for teams "newer to AI coding tools." Picking this with 5 experienced engineers signals you're playing it safe.
- Limited scope for a "wow factor" in the demo. It's a form. A nice form, but a form.
- Harder to differentiate from other teams doing the same challenge.

**Verdict:** Easy win on execution, hard win on standing out.

---

## Challenge 2: Unlocking the Dark Data

### What it is
Make government guidance/policy genuinely searchable and answerable. Think: a structured search or Q&A interface over GOV.UK-style content.

### Feasibility: ★★★☆☆ (Medium)

**Pros:**
- High impact story — directly tied to GOV.UK App ambitions. Judges will recognise the relevance.
- Clear demo: "ask a question, get a real answer with source" is viscerally impressive.
- Plenty of publicly available GOV.UK content to work with.
- Good AI tool story — using Copilot to build the ingestion pipeline, search index, and UI.

**Cons:**
- **The interesting version requires an LLM for RAG/Q&A.** Without API access, you're either mocking (underwhelming demo), BYO-ing (setup time), or running local models (resource constraints).
- Content structuring/ingestion is a time sink. Scraping, parsing, chunking GOV.UK content in 5 hours is ambitious.
- If you mock the AI, the demo is basically a search engine with extra steps.
- Risk of spending 3 hours on infrastructure and 1 hour on the thing judges actually see.

**Verdict:** High ceiling, high floor. Only viable if someone on the team has LLM API access ready to go AND you pre-plan the architecture tightly.

---

## Challenge 3: Supporting Casework Decisions

### What it is
A tool that helps caseworkers by surfacing relevant case information, applicable policies, evidence status, and next actions. Plus a team leader dashboard for caseload risk visibility.

### Feasibility: ★★★★☆ (High)

**Pros:**
- Multiple demo surfaces: caseworker view, team leader dashboard, applicant status page — three user journeys from one codebase.
- Very demo-friendly. Dashboards with charts, traffic-light risk indicators, case timelines — visually impressive.
- Synthetic data is easy to generate (cases, statuses, evidence checklists, policy mappings). AI tools can generate realistic datasets fast.
- Clear story: "caseworkers spend 60% of time on admin, we gave them back that time."
- **Doesn't require an LLM** — the core value is in aggregation, presentation, and workflow, not in AI inference.
- Parallelisable: one pair on caseworker UI, one pair on dashboard/analytics, one on data/API layer.

**Cons:**
- Scope creep risk. Three personas = three views = potential for spreading too thin.
- Needs disciplined scoping — pick ONE case type, ONE workflow, nail it.
- Less "innovative" than Challenge 2 — it's essentially a well-designed internal tool.

**Verdict:** Strong balance of ambition and achievability. Very parallelisable across 5 people.

---

## Challenge 4: Knowing Your Own Organisation

### What it is
An internal dashboard that gives leaders visibility over people, projects, and workload across the organisation — answerable questions like "how many people are on Programme X" or "which teams are under pressure."

### Feasibility: ★★★★☆ (High)

**Pros:**
- Dashboard/analytics prototypes are fast to build and visually impressive.
- Natural language query over organisational data is a strong demo moment (even with simple NL-to-SQL).
- Synthetic data generation is trivial: org chart, project allocations, workload metrics.
- Clear value proposition that every senior leader in the room will relate to.
- Good AI tool story — Copilot generating chart components, data models, query logic.

**Cons:**
- Overlaps with Challenge 3 in format (dashboards, data aggregation).
- "Dashboard over fake data" can feel hollow if not carefully designed.
- The NL query angle needs an LLM or very clever regex/keyword matching to be convincing.
- Less emotionally compelling than citizen-facing challenges (no "real person waiting for their passport" story).

**Verdict:** Strong technically, slightly weaker on the narrative/impact story compared to Challenge 3.

---

## Strategic Recommendation

### Pick Challenge 3: Supporting Casework Decisions

**Why:**

| Factor | Challenge 1 | Challenge 2 | Challenge 3 | Challenge 4 |
|--------|:-----------:|:-----------:|:-----------:|:-----------:|
| Achievable in 5 hours | ✅✅✅ | ⚠️ | ✅✅ | ✅✅ |
| Demo impact | ⚠️ | ✅✅✅ | ✅✅✅ | ✅✅ |
| Differentiation | ❌ | ✅✅ | ✅✅ | ✅ |
| No LLM dependency | ✅✅✅ | ❌ | ✅✅✅ | ⚠️ |
| Parallelisable (5 people) | ⚠️ | ⚠️ | ✅✅✅ | ✅✅ |
| Narrative/impact story | ✅ | ✅✅ | ✅✅✅ | ✅ |
| Milestone velocity | ✅✅✅ | ⚠️ | ✅✅ | ✅✅ |

**The winning formula for your team:**

1. **Challenge 3 is the Goldilocks option.** Not so simple that it looks lazy (Ch1), not so dependent on LLM access that it's risky (Ch2), and has a stronger human story than Ch4.

2. **It parallelises perfectly across 5 engineers:**
   - Engineer 1-2: Caseworker UI (case view, evidence checklist, policy lookup, next actions)
   - Engineer 3: Team leader dashboard (caseload heatmap, risk indicators, bottleneck alerts)
   - Engineer 4: Applicant status page (simple "where is my case" tracker)
   - Engineer 5: Data layer + synthetic data generation + API

3. **It hits milestones fast.** Repo setup → data model → first API → first UI component → first user journey. Each is a visible checkpoint.

4. **The AI tool story writes itself.** "We used Copilot to generate our case data model, all CRUD operations, React components for the dashboard, and test coverage — in 5 hours we built three complete user journeys."

5. **The judge narrative is strong.** "A caseworker opens their morning view and immediately sees: 3 cases need urgent action, 2 have new evidence arrived, 1 is overdue. No digging. No reading through notes. The applicant can check their own status. The team leader can see which caseworker is overloaded."

### If You Have LLM API Access

If someone on the team has OpenAI/Anthropic/etc. API access ready to go, **consider Challenge 2 instead** — the demo impact of a working Q&A system over real GOV.UK content is hard to beat. But only if you can commit to having the API plumbed in within the first 30 minutes.

---

## Suggested Tech Stack (Challenge 3)

- **Framework**: Ruby on Rails 8 monolith (convention over configuration — less debating, more building)
- **Frontend**: Rails views with Hotwire (Turbo + Stimulus) + Tailwind CSS (ships with Rails 8)
- **Database**: SQLite via ActiveRecord (Rails default, zero config, portable, demoable)
- **Data**: AI-generated synthetic casework data (generate with Copilot via `db/seeds.rb` in first 30 mins)
- **Charts**: Chartkick + Groupdate for dashboard visualisations (one-liner charts, Rails-native)

Keep it simple. Judges don't care about your Kubernetes cluster. They care about a working demo and a good story.
