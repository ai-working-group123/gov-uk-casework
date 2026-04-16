# UX Wireframes — Challenge 3: Supporting Casework Decisions

All wireframes use GOV.UK-inspired design language: clean, minimal, high contrast, accessible.

---

## Screen 1: Caseworker Dashboard (Morning View)

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏛️  Case Management Service              Sarah Chen │ Sign out   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Good morning, Sarah. Here's your caseload for today.              │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────┐ │
│  │      12      │  │      3       │  │      1       │  │   2    │ │
│  │  Active cases │  │ Need action  │  │   Overdue    │  │ New    │ │
│  │              │  │    today     │  │  ⚠️ URGENT   │  │ today  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └────────┘ │
│                                                                     │
│  ┌─ Filters ──────────────────────────────────────────────────────┐ │
│  │ Status: [All ▾]  Priority: [All ▾]  Type: [All ▾]  🔍 Search │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Ref        │ Applicant      │ Type    │ Status     │ Priority │ │
│  ├────────────┼────────────────┼─────────┼────────────┼──────────┤ │
│  │ VIS-2024-  │ Priya Sharma   │ Tier 2  │ ⚠️ OVERDUE │ 🔴 High │ │
│  │ 00847      │                │ Work    │ Awaiting   │          │ │
│  │            │                │         │ evidence   │          │ │
│  ├────────────┼────────────────┼─────────┼────────────┼──────────┤ │
│  │ VIS-2024-  │ Marco Rossi    │ Tier 4  │ 🟡 Action  │ 🟡 Med  │ │
│  │ 00891      │                │ Student │ needed     │          │ │
│  ├────────────┼────────────────┼─────────┼────────────┼──────────┤ │
│  │ VIS-2024-  │ Aisha Hassan   │ Family  │ 🟢 On      │ 🟢 Low  │ │
│  │ 00902      │                │ Visa    │ track      │          │ │
│  ├────────────┼────────────────┼─────────┼────────────┼──────────┤ │
│  │ VIS-2024-  │ Chen Wei       │ Tier 2  │ 🟡 Action  │ 🟡 Med  │ │
│  │ 00915      │                │ Work    │ needed     │          │ │
│  ├────────────┼────────────────┼─────────┼────────────┼──────────┤ │
│  │ VIS-2024-  │ James O'Brien  │ Tier 4  │ 🔵 New     │ 🟢 Low  │ │
│  │ 00923      │                │ Student │            │          │ │
│  └────────────┴────────────────┴─────────┴────────────┴──────────┘ │
│                                                                     │
│  Showing 5 of 12 cases                          « 1 2 3 »         │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions
- **Morning briefing summary** at top — caseworker knows their day in 2 seconds
- **Colour-coded status/priority** — red/amber/green, universally understood
- **Overdue cases float to top** — most urgent first
- **Click any row → Case Detail page**

---

## Screen 2: Case Detail Page

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏛️  Case Management Service              Sarah Chen │ Sign out   │
├─────────────────────────────────────────────────────────────────────┤
│  ← Back to dashboard                                               │
│                                                                     │
│  ┌─ Case VIS-2024-00847 ─────────────────────────────────────────┐ │
│  │                                                                │ │
│  │  Applicant: Priya Sharma          Status: ⚠️ OVERDUE          │ │
│  │  Type: Tier 2 (General) Work      Priority: 🔴 High           │ │
│  │  Submitted: 12 Feb 2024           SLA deadline: 28 Mar 2024   │ │
│  │  Assigned to: Sarah Chen          Days overdue: 13            │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ What you need to do ─────────────────────────────────────────┐ │
│  │                                                                │ │
│  │  🔴  Chase missing evidence: employer sponsorship certificate  │ │
│  │      Due: 15 Mar 2024 (28 days ago)                           │ │
│  │      [Mark as received]  [Send reminder]                      │ │
│  │                                                                │ │
│  │  🟡  Review financial evidence once sponsorship received       │ │
│  │      Blocked by: missing sponsorship certificate               │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─── Evidence ──────────┐  ┌─── Applicable Policy ─────────────┐ │
│  │                       │  │                                    │ │
│  │  ✅ Passport (valid)  │  │  📋 Immigration Rules Part 6A     │ │
│  │  ✅ English language  │  │     Tier 2 (General) requirements  │ │
│  │  ✅ TB certificate    │  │                                    │ │
│  │  ✅ Bank statements   │  │  Key criteria:                     │ │
│  │  ❌ Sponsorship cert  │  │  • Valid CoS from licensed sponsor │ │
│  │     ⚠️ 28 days late   │  │  • Minimum salary threshold met   │ │
│  │  ⬜ Biometrics        │  │  • English language requirement    │ │
│  │     (not yet required)│  │  • Maintenance funds available     │ │
│  │                       │  │                                    │ │
│  │  4/6 received         │  │  [View full policy →]              │ │
│  └───────────────────────┘  └────────────────────────────────────┘ │
│                                                                     │
│  ┌─ Case Timeline ───────────────────────────────────────────────┐ │
│  │                                                                │ │
│  │  10 Apr  Sarah Chen      Reviewed — chasing sponsorship cert  │ │
│  │  28 Mar  SYSTEM          ⚠️ SLA deadline passed               │ │
│  │  15 Mar  Sarah Chen      Reminder sent to applicant           │ │
│  │  01 Mar  Sarah Chen      Financial docs reviewed - OK         │ │
│  │  14 Feb  SYSTEM          Case assigned to Sarah Chen          │ │
│  │  12 Feb  Applicant       Application submitted                │ │
│  │                                                                │ │
│  │  [Add note]                                                   │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions
- **"What you need to do" is THE first thing** — not buried under case history
- **Evidence checklist** — instant visibility of what's in and what's missing
- **Applicable policy sidebar** — no more hunting through guidance docs
- **Timeline** — full audit trail, most recent first
- **Action buttons inline** — caseworker acts from this page, doesn't navigate away

---

## Screen 3: Team Leader Dashboard

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏛️  Case Management Service          James Morton │ Sign out     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Team Overview — Visa Processing Unit                              │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────┐ │
│  │      47      │  │      8       │  │      3       │  │  89%   │ │
│  │ Total active │  │   Overdue    │  │  High risk   │  │  SLA   │ │
│  │    cases     │  │  ⚠️ WARNING  │  │  🔴 ALERT    │  │  rate  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └────────┘ │
│                                                                     │
│  ┌─ Caseload by Caseworker ──────────────────────────────────────┐ │
│  │                                                                │ │
│  │  Sarah Chen     ████████████████████░░░░  12 cases  ⚠️ 1 OD  │ │
│  │  David Park     ██████████████░░░░░░░░░░   9 cases            │ │
│  │  Fatima Ali     ████████████████████████  15 cases  🔴 3 OD  │ │
│  │  Tom Hughes     ████████░░░░░░░░░░░░░░░░   5 cases            │ │
│  │  Nia Williams   ██████████░░░░░░░░░░░░░░   6 cases  ⚠️ 1 OD  │ │
│  │                                                                │ │
│  │  ░░ = capacity remaining    OD = overdue cases                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ Risk Overview ──────────────┐  ┌─ Cases Approaching SLA ────┐ │
│  │                              │  │                             │ │
│  │  🔴 High risk (3)           │  │  VIS-00847  2 days left     │ │
│  │  • VIS-00847 - 13d overdue  │  │  VIS-00891  4 days left     │ │
│  │  • VIS-00734 - 7d overdue   │  │  VIS-00856  5 days left     │ │
│  │  • VIS-00612 - 5d overdue   │  │  VIS-00903  7 days left     │ │
│  │                              │  │                             │ │
│  │  🟡 Medium risk (5)         │  │  [View all →]               │ │
│  │  • 3 approaching SLA        │  │                             │ │
│  │  • 2 missing evidence >14d  │  └─────────────────────────────┘ │
│  │                              │                                  │
│  │  🟢 Low risk (39)           │  ┌─ This Week ─────────────────┐ │
│  │                              │  │                             │ │
│  │  [View all cases →]         │  │  New cases:        7        │ │
│  └──────────────────────────────┘  │  Decisions made:   11       │ │
│                                     │  Avg processing:  18 days  │ │
│                                     │  SLA compliance:  89%      │ │
│                                     └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions
- **Workload bar chart** — instantly see who's overloaded (Fatima is drowning, Tom has capacity)
- **Risk categorisation** — not just overdue, but approaching-SLA gives early warning
- **Clickable everywhere** — caseworker name → their caseload, case ref → case detail
- **Weekly stats** — trends matter as much as snapshots

---

## Screen 4: Applicant Status Portal (Public-Facing)

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  GOV.UK                                                            │
│  ─────────────────────────────────────────────────                 │
│                                                                     │
│  Check the status of your visa application                         │
│                                                                     │
│  Enter your application reference number.                          │
│  You can find this on the confirmation email you received          │
│  when you submitted your application.                              │
│                                                                     │
│  Application reference                                             │
│  ┌────────────────────────────────┐                                │
│  │ VIS-2024-00847                 │                                │
│  └────────────────────────────────┘                                │
│                                                                     │
│  [Check status]                                                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘


                            ↓ After submission ↓


┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  GOV.UK                                                            │
│  ─────────────────────────────────────────────────                 │
│                                                                     │
│  Application VIS-2024-00847                                        │
│                                                                     │
│  Tier 2 (General) Work Visa                                        │
│                                                                     │
│  Current status                                                    │
│  ┌────────────────────────────────────────────────────────────────┐│
│  │  ⏳ Awaiting evidence                                         ││
│  │                                                                ││
│  │  We are waiting to receive some of the documents needed to    ││
│  │  process your application. You do not need to do anything —   ││
│  │  we have contacted the relevant party directly.               ││
│  └────────────────────────────────────────────────────────────────┘│
│                                                                     │
│  Timeline                                                          │
│                                                                     │
│  ● 15 Mar 2024 — Reminder sent for outstanding documents          │
│  │                                                                 │
│  ● 01 Mar 2024 — Your financial documents were reviewed            │
│  │                                                                 │
│  ● 14 Feb 2024 — Your application was assigned to a caseworker     │
│  │                                                                 │
│  ● 12 Feb 2024 — Application received                              │
│  │                                                                 │
│  ○ Submitted                                                       │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐│
│  │  What happens next                                            ││
│  │                                                                ││
│  │  Once we have received all required documents, your           ││
│  │  application will be reviewed. Most applications receive a    ││
│  │  decision within 8 weeks of all evidence being received.      ││
│  └────────────────────────────────────────────────────────────────┘│
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions
- **GOV.UK style** — familiar, trustworthy, accessible
- **Plain English status** — not internal jargon. "Awaiting evidence" not "PENDING_DOCS"
- **Friendly timeline** — applicant sees progress without internal case notes
- **"What happens next"** — reduces anxiety and phone calls
- **No sensitive details exposed** — applicant sees their journey, not internal workings

---

## Screen 5: Request Evidence from Applicant (Caseworker View)

Accessed from Case Detail page → `[Request evidence]` button in the "What you need to do" or "Evidence" panel.

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏛️  Case Management Service              Sarah Chen │ Sign out   │
├─────────────────────────────────────────────────────────────────────┤
│  ← Back to case VIS-2024-00847                                     │
│                                                                     │
│  Request evidence from applicant                                   │
│                                                                     │
│  Applicant: Priya Sharma                                           │
│  Case type: Tier 2 (General) Work                                  │
│                                                                     │
│  ┌─ Items to request ────────────────────────────────────────────┐ │
│  │                                                                │ │
│  │  Item 1                                                       │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ Evidence type  [Sponsorship certificate ▾]               │ │ │
│  │  │                                                          │ │ │
│  │  │ Submission method                                        │ │ │
│  │  │ ● Digital upload (applicant uploads via portal)          │ │ │
│  │  │ ○ Physical post (applicant posts original document)      │ │ │
│  │  │ ○ Either (applicant chooses)                             │ │ │
│  │  │                                                          │ │ │
│  │  │ Why this is needed                                       │ │ │
│  │  │ ┌──────────────────────────────────────────────────────┐ │ │ │
│  │  │ │ A valid Certificate of Sponsorship from a licensed   │ │ │ │
│  │  │ │ sponsor is required under Immigration Rules Part 6A. │ │ │ │
│  │  │ └──────────────────────────────────────────────────────┘ │ │ │
│  │  │ Linked policy: 📋 Part 6A — Tier 2 (General) §245H     │ │ │
│  │  │                                                          │ │ │
│  │  │ Deadline  ┌────────────┐                                 │ │ │
│  │  │           │ 30 Apr 2024│  (14 days from today)           │ │ │
│  │  │           └────────────┘                                 │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  │                                                                │ │
│  │  Item 2                                                       │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ Evidence type  [Employer letter ▾]                       │ │ │
│  │  │                                                          │ │ │
│  │  │ Submission method                                        │ │ │
│  │  │ ○ Digital upload (applicant uploads via portal)          │ │ │
│  │  │ ● Physical post (applicant posts original document)      │ │ │
│  │  │ ○ Either (applicant chooses)                             │ │ │
│  │  │                                                          │ │ │
│  │  │ Why this is needed                                       │ │ │
│  │  │ ┌──────────────────────────────────────────────────────┐ │ │ │
│  │  │ │ Original signed letter from your employer confirming │ │ │ │
│  │  │ │ your role, salary, and start date.                   │ │ │ │
│  │  │ └──────────────────────────────────────────────────────┘ │ │ │
│  │  │ Linked policy: 📋 Part 6A — Tier 2 (General) §245HB    │ │ │
│  │  │                                                          │ │ │
│  │  │ Deadline  ┌────────────┐                                 │ │ │
│  │  │           │ 30 Apr 2024│  (14 days from today)           │ │ │
│  │  │           └────────────┘                                 │ │ │
│  │  │                                                          │ │ │
│  │  │  ⚠️ Physical post selected — postal address will be     │ │ │
│  │  │  included in the applicant's instructions.               │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  │                                                                │ │
│  │  [+ Add another item]                                         │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ Notification to applicant ───────────────────────────────────┐ │
│  │                                                                │ │
│  │  Notify via:  ☑ Email   ☑ Portal message   ☐ SMS             │ │
│  │                                                                │ │
│  │  Preview of applicant message:                                │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ Dear Priya Sharma,                                      │ │ │
│  │  │                                                          │ │ │
│  │  │ We need some additional documents to continue processing │ │ │
│  │  │ your Tier 2 (General) Work Visa application              │ │ │
│  │  │ (ref: VIS-2024-00847).                                  │ │ │
│  │  │                                                          │ │ │
│  │  │ Please provide the following by 30 April 2024:           │ │ │
│  │  │                                                          │ │ │
│  │  │ 1. Sponsorship certificate                               │ │ │
│  │  │    Upload via your application portal.                   │ │ │
│  │  │                                                          │ │ │
│  │  │ 2. Employer letter (original required)                   │ │ │
│  │  │    Post to: Visa Processing Centre, PO Box 1234,        │ │ │
│  │  │    Sheffield, S1 2AB. Write your reference number on     │ │ │
│  │  │    the envelope.                                         │ │ │
│  │  │                                                          │ │ │
│  │  │ If we do not receive these documents by the deadline,    │ │ │
│  │  │ your application may be decided based on the evidence    │ │ │
│  │  │ already provided.                                        │ │ │
│  │  │                                                          │ │ │
│  │  │ Check your application status:                           │ │ │
│  │  │ https://www.gov.uk/check-visa-status                    │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  │                                                                │ │
│  │  [Edit message]                                               │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  [Send request]   [Save as draft]   [Cancel]                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions
- **Multiple items per request** — caseworker batches everything in one go, applicant gets one clear message
- **Submission method per item** — digital vs physical vs either, because a scanned sponsorship cert is fine but an original employer letter on headed paper might not be
- **Policy linkage** — every request is traceable to a policy requirement, not caseworker whim
- **Deadline with context** — shows both date and "X days from today" so the caseworker can calibrate
- **Message preview** — caseworker sees exactly what the applicant will receive before sending
- **Physical post instructions auto-included** — when "physical post" is selected, the postal address and envelope-labelling guidance appear automatically
- **Multi-channel notification** — email + portal + optional SMS to maximise reach
- **Consequence warning in letter** — plain English: if you don't send it, we decide without it

---

## Screen 6: Applicant Action Required (Public-Facing Portal)

When an evidence request is active, the applicant's status page changes to show what's needed.

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  GOV.UK                                                            │
│  ─────────────────────────────────────────────────                 │
│                                                                     │
│  Application VIS-2024-00847                                        │
│                                                                     │
│  Tier 2 (General) Work Visa                                        │
│                                                                     │
│  Current status                                                    │
│  ┌────────────────────────────────────────────────────────────────┐│
│  │  🟠 Action needed — we need documents from you               ││
│  │                                                                ││
│  │  We need some additional documents before we can continue      ││
│  │  processing your application. Please provide them by           ││
│  │  30 April 2024.                                               ││
│  └────────────────────────────────────────────────────────────────┘│
│                                                                     │
│  ┌─ What you need to provide ────────────────────────────────────┐ │
│  │                                                                │ │
│  │  1. Sponsorship certificate                                   │ │
│  │     A valid Certificate of Sponsorship from a licensed        │ │
│  │     sponsor.                                                  │ │
│  │     How to submit: Upload a copy below.                       │ │
│  │     Status: ❌ Not yet received                               │ │
│  │     [Upload document]                                         │ │
│  │                                                                │ │
│  │  ─────────────────────────────────────────────────────────    │ │
│  │                                                                │ │
│  │  2. Employer letter (original document required)              │ │
│  │     Original signed letter from your employer confirming      │ │
│  │     your role, salary, and start date.                        │ │
│  │     How to submit: Post the original document to:             │ │
│  │                                                                │ │
│  │     ┌──────────────────────────────────────────────────────┐  │ │
│  │     │  Visa Processing Centre                              │  │ │
│  │     │  PO Box 1234                                         │  │ │
│  │     │  Sheffield                                           │  │ │
│  │     │  S1 2AB                                              │  │ │
│  │     │                                                      │  │ │
│  │     │  Write your reference number (VIS-2024-00847) on     │  │ │
│  │     │  the front of the envelope.                          │  │ │
│  │     └──────────────────────────────────────────────────────┘  │ │
│  │     Status: ❌ Not yet received                               │ │
│  │                                                                │ │
│  │  Deadline: 30 April 2024                                      │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐│
│  │  What happens if I cannot provide these documents?            ││
│  │                                                                ││
│  │  If we do not receive all requested documents by the          ││
│  │  deadline, your application may be decided based on the       ││
│  │  evidence we already have.                                    ││
│  │                                                                ││
│  │  If you are having difficulty obtaining a document,           ││
│  │  contact us quoting your reference number.                    ││
│  └────────────────────────────────────────────────────────────────┘│
│                                                                     │
│  Timeline                                                          │
│                                                                     │
│  ● 16 Apr 2024 — We asked you to provide additional documents     │
│  │                                                                 │
│  ● 15 Mar 2024 — Reminder sent for outstanding documents          │
│  │                                                                 │
│  ● 01 Mar 2024 — Your financial documents were reviewed            │
│  │                                                                 │
│  ● 14 Feb 2024 — Your application was assigned to a caseworker     │
│  │                                                                 │
│  ● 12 Feb 2024 — Application received                              │
│  │                                                                 │
│  ○ Submitted                                                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions
- **Status changes from passive to active** — "Action needed" with orange indicator replaces "Awaiting evidence"
- **Per-item submission instructions** — crystal clear whether to upload or post, no ambiguity
- **Postal address in a highlighted box** — easy to copy or screenshot
- **Reference number on envelope** — prevents physical documents getting lost in a mailroom
- **Consequence section** — honest but not threatening, with an escape hatch ("contact us")
- **Items update independently** — once the digital upload is received, item 1 shows ✅ while item 2 may still show ❌

---

## Screen 7: Applicant Document Upload (Public-Facing Portal)

Reached by clicking `[Upload document]` on Screen 6.

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  GOV.UK                                                            │
│  ─────────────────────────────────────────────────                 │
│                                                                     │
│  Upload document — Sponsorship certificate                         │
│                                                                     │
│  Application: VIS-2024-00847                                       │
│                                                                     │
│  Upload a copy of your Certificate of Sponsorship.                 │
│                                                                     │
│  The file must be:                                                 │
│  • a PDF, JPG, or PNG                                              │
│  • smaller than 10MB                                               │
│  • a clear, readable scan or photograph                            │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐│
│  │                                                                ││
│  │              Drag and drop your file here                      ││
│  │                       or                                       ││
│  │                 [Choose file]                                  ││
│  │                                                                ││
│  └────────────────────────────────────────────────────────────────┘│
│                                                                     │
│                                                                     │
│                     ↓ After file selected ↓                        │
│                                                                     │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐│
│  │  📄 sponsorship_certificate.pdf (2.3 MB)          [Remove]    ││
│  └────────────────────────────────────────────────────────────────┘│
│                                                                     │
│  Is there anything else you want to tell us about this document?  │
│  (optional)                                                        │
│  ┌────────────────────────────────────────────────────────────────┐│
│  │                                                                ││
│  └────────────────────────────────────────────────────────────────┘│
│                                                                     │
│  [Upload document]                                                 │
│                                                                     │
│                                                                     │
│                    ↓ After successful upload ↓                     │
│                                                                     │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐│
│  │  ✅ Your document has been uploaded successfully.              ││
│  │                                                                ││
│  │  We will review it as part of your application. You do not    ││
│  │  need to do anything else for this document.                  ││
│  └────────────────────────────────────────────────────────────────┘│
│                                                                     │
│  [Return to your application status]                               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions
- **One document per upload** — avoids confusion about which file is which
- **Clear file requirements** — format, size, quality upfront to reduce rejected uploads
- **Optional note field** — applicant can explain context ("issued under my maiden name" etc.)
- **Immediate confirmation** — reduces anxiety, no guessing whether it worked
- **No account required** — accessible via reference number, consistent with GOV.UK patterns
- **File type validation client-side** — stops the user before they waste time uploading a .docx

---

## Screen 8: Evidence Request Tracker (Caseworker View — Case Detail Enhancement)

After an evidence request has been sent, the Evidence panel on the Case Detail page (Screen 2) updates to show request status.

```
┌─── Evidence ─────────────────────────────────────────────────────┐
│                                                                   │
│  ✅ Passport (valid)             Received 12 Feb 2024            │
│  ✅ English language cert        Received 12 Feb 2024            │
│  ✅ TB certificate               Received 12 Feb 2024            │
│  ✅ Bank statements              Received 12 Feb 2024            │
│                                                                   │
│  ── Requested 16 Apr 2024 — deadline 30 Apr 2024 (14 days) ──   │
│                                                                   │
│  📤 Sponsorship certificate     Requested — awaiting upload      │
│     📎 Digital upload                                            │
│     [Mark as received]  [Send reminder]  [Extend deadline]       │
│                                                                   │
│  📮 Employer letter              Requested — awaiting post       │
│     ✉️ Physical: PO Box 1234, Sheffield S1 2AB                   │
│     [Mark as received]  [Send reminder]  [Extend deadline]       │
│                                                                   │
│  ⬜ Biometrics                   Not yet required                │
│                                                                   │
│  4/6 received · 2 requested · deadline in 14 days                │
│                                                                   │
│  [Request more evidence]                                         │
└───────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions
- **Requested items visually distinct** — 📤 (digital) and 📮 (physical) icons differentiate submission method at a glance
- **Grouped by request date** — caseworker sees which batch items belong to
- **Per-item actions** — mark received (when post arrives), send a reminder, or extend the deadline independently
- **Running tally** — "4/6 received · 2 requested · deadline in 14 days" gives instant progress
- **Physical post shows address** — caseworker can confirm where the applicant was told to send it
- **Extend deadline** — real-world flexibility without losing the audit trail
