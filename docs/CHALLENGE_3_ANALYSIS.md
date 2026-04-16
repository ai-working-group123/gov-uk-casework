# Challenge 3 Analysis: UK Government Casework Domains

## Why This Matters

The challenge says "caseworkers across government." Your prototype uses visa/immigration — good call, universally understood. But to impress judges, you need to show you _understand the pattern_ across government, not just one silo. This document gives you the domain knowledge to seed realistic data and defend your design choices.

> **See also:** [Part 7: DVLA Vehicle Changes Deep Dive](#part-7-deep-dive--dvla-vehicle-changes-v5c) at the end of this document — a complete second casework domain with full decision logic, evidence requirements, and seed data scenarios sourced directly from GOV.UK.

---

## Part 1: Real UK Government Casework Domains

### 1. UKVI — Visa & Immigration (Your chosen domain)

**Organisation:** UK Visas and Immigration (Home Office)
**Volume:** ~3 million visa decisions per year
**Caseworkers:** ~6,000+

> **References:**
>
> - [Immigration Rules (full)](https://www.gov.uk/guidance/immigration-rules)
> - [Skilled Worker visa](https://www.gov.uk/skilled-worker-visa) · [Appendix Skilled Worker](https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-skilled-worker)
> - [Student visa](https://www.gov.uk/student-visa) · [Appendix Student](https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-student)
> - [Family visa](https://www.gov.uk/uk-family-visa) · [Appendix FM](https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-fm-family-members)
> - [Indefinite Leave to Remain](https://www.gov.uk/indefinite-leave-to-remain)
> - [Standard Visitor visa](https://www.gov.uk/standard-visitor)
> - [Claim asylum](https://www.gov.uk/claim-asylum)

| Case Type                        | Typical SLA                   | Decision Complexity                           |
| -------------------------------- | ----------------------------- | --------------------------------------------- |
| Skilled Worker (was Tier 2)      | 8 weeks (3 weeks priority)    | Medium — checklist-heavy                      |
| Student Visa (was Tier 4)        | 3 weeks                       | Low — mostly pass/fail                        |
| Family/Spouse Visa               | 12 weeks (24 weeks complex)   | High — subjective relationship evidence       |
| Indefinite Leave to Remain (ILR) | 6 months                      | High — full history review                    |
| Standard Visitor                 | 3 weeks                       | Low — mostly automated now                    |
| Asylum                           | 6 months target (often years) | Very high — interview-based, country evidence |

---

### 2. DWP — Benefits Casework

**Organisation:** Department for Work and Pensions
**Volume:** ~6 million Universal Credit claims active; ~2.6 million PIP claimants
**Caseworkers:** Tens of thousands (called "work coaches" for UC, "health assessors" for PIP)

> **References:**
>
> - [Universal Credit](https://www.gov.uk/universal-credit)
> - [Personal Independence Payment (PIP)](https://www.gov.uk/pip)
> - [Employment and Support Allowance (ESA)](https://www.gov.uk/employment-support-allowance)
> - [State Pension](https://www.gov.uk/state-pension)
> - [Carer's Allowance](https://www.gov.uk/carers-allowance)

| Case Type                            | Typical SLA               | Decision Complexity                            |
| ------------------------------------ | ------------------------- | ---------------------------------------------- |
| Universal Credit (new claim)         | 5 weeks (first payment)   | Medium — verify identity, housing, income      |
| Universal Credit (change of circs)   | Varies                    | Low-Medium — recalculation                     |
| PIP (Personal Independence Payment)  | 16 weeks target           | High — medical evidence, functional assessment |
| ESA (Employment & Support Allowance) | 13 weeks                  | High — Work Capability Assessment              |
| State Pension                        | 10 days (straightforward) | Low — NI record lookup                         |
| Carer's Allowance                    | 12 weeks                  | Medium — verify caring relationship            |

---

### 3. HMRC — Tax Casework

**Organisation:** HM Revenue & Customs
**Volume:** ~12 million Self Assessment returns; ~2.4 million VAT-registered businesses
**Caseworkers:** ~60,000 staff total

> **References:**
>
> - [Self Assessment tax returns](https://www.gov.uk/self-assessment-tax-returns)
> - [Tax credits](https://www.gov.uk/tax-credits)
> - [R&D tax relief](https://www.gov.uk/guidance/corporation-tax-research-and-development-rd-relief)
> - [VAT registration](https://www.gov.uk/vat-registration)
> - [Tax compliance checks](https://www.gov.uk/tax-compliance-checks)
> - [Marriage Allowance](https://www.gov.uk/marriage-allowance)

| Case Type                   | Typical SLA                      | Decision Complexity              |
| --------------------------- | -------------------------------- | -------------------------------- |
| Self Assessment enquiry     | 12 months                        | High — financial evidence review |
| Tax credits renewal         | 4 weeks                          | Low — automated with exceptions  |
| R&D tax relief claim        | 28 days (small), 40 days (large) | Medium — technical assessment    |
| VAT registration            | 30 days                          | Low-Medium                       |
| Compliance check            | 3-12 months                      | Very high — investigative        |
| Marriage Allowance transfer | 2 weeks                          | Low                              |

---

### 4. Home Office — Asylum & Refugee

**Organisation:** Home Office (separate from UKVI mainstream)
**Volume:** ~90,000 initial decisions/year (2024-25 backlog still significant)
**Caseworkers:** ~2,500+

> **References:**
>
> - [Claim asylum in the UK](https://www.gov.uk/claim-asylum)
> - [Asylum support](https://www.gov.uk/asylum-support)
> - [Immigration Rules Part 11: Asylum](https://www.gov.uk/guidance/immigration-rules/immigration-rules-part-11-asylum)
> - [Refugee family reunion](https://www.gov.uk/guidance/immigration-rules/immigration-rules-part-11-asylum#family-reunion)

| Case Type                         | Typical SLA       | Decision Complexity                             |
| --------------------------------- | ----------------- | ----------------------------------------------- |
| Initial asylum claim              | 6 months (target) | Very high — substantive interview, country info |
| Fresh claim (further submissions) | No fixed SLA      | High — assess materiality of new evidence       |
| Family reunion                    | 12 weeks          | Medium                                          |
| Deportation appeal                | Varies            | Very high — legal complexity                    |

---

### 5. HMCTS — Courts & Tribunals

**Organisation:** HM Courts & Tribunals Service (MoJ)
**Volume:** ~4.4 million cases/year across all jurisdictions
**Caseworkers:** Court clerks, legal advisers, listing officers

> **References:**
>
> - [Immigration and asylum tribunal](https://www.gov.uk/immigration-asylum-tribunal)
> - [Appeal a benefit decision (social security tribunal)](https://www.gov.uk/appeal-benefit-decision)
> - [Make a claim to an employment tribunal](https://www.gov.uk/employment-tribunals)
> - [Family court — apply for a court order (C100)](https://www.gov.uk/looking-after-children-divorce/apply-for-court-order)

| Case Type                            | Typical SLA                    | Decision Complexity        |
| ------------------------------------ | ------------------------------ | -------------------------- |
| Immigration & Asylum tribunal appeal | 6 weeks (paper), > for hearing | High                       |
| Social security tribunal appeal      | 30 weeks                       | Medium                     |
| Employment tribunal claim            | 6 months to hearing            | Medium-High                |
| Family court application (C100)      | 26 weeks target                | Very high                  |
| Criminal case listing                | Varies                         | Medium — resource matching |

---

### 6. Local Authority — Housing & Social Care

**Volume:** Varies by council
**Caseworkers:** Housing officers, social workers

> **References:**
>
> - [Homelessness: duty of local authorities](https://www.gov.uk/guidance/homelessness-code-of-guidance-for-local-authorities)
> - [Council Tax Reduction](https://www.gov.uk/council-tax-reduction)
> - [Housing Benefit](https://www.gov.uk/housing-benefit)
> - [Care and support statutory guidance (adult social care)](https://www.gov.uk/government/publications/care-act-statutory-guidance)
> - [Working Together to Safeguard Children](https://www.gov.uk/government/publications/working-together-to-safeguard-children--2)

| Case Type                       | Typical SLA                          | Decision Complexity             |
| ------------------------------- | ------------------------------------ | ------------------------------- |
| Homelessness assessment         | 56 days (duty period)                | High — vulnerability assessment |
| Council Tax Reduction           | 14 days                              | Low — means testing             |
| Housing Benefit                 | 14 days (new), 7 days (change)       | Low-Medium                      |
| Adult social care assessment    | 28 days                              | High — needs-based              |
| Children's social care referral | 1 day (triage), 45 days (assessment) | Very high                       |

---

## Part 2: Deep Dive — Visa/Immigration Data & Next-Action Logic

Since you're building this domain, here's the real-world detail.

### Skilled Worker Visa — Evidence Requirements

> **Policy source:** [Immigration Rules Appendix Skilled Worker](https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-skilled-worker) · [Skilled Worker visa guidance](https://www.gov.uk/skilled-worker-visa) · [TB test countries list](https://www.gov.uk/tb-test-visa/countries-where-you-need-a-tb-test) · [ATAS](https://www.gov.uk/academic-technology-approval-scheme) · [Sponsor licence guidance](https://www.gov.uk/uk-visa-sponsorship-employers)

| Evidence                         | Required?   | Source                           | Verification Method                                             |
| -------------------------------- | ----------- | -------------------------------- | --------------------------------------------------------------- |
| Valid passport                   | Mandatory   | Applicant                        | Check expiry, nationality                                       |
| Certificate of Sponsorship (CoS) | Mandatory   | Sponsor (employer)               | SMS system lookup — unique ref                                  |
| Proof of English language        | Mandatory   | Test centre / nationality exempt | Check approved test list, CEFR B1+                              |
| TB test certificate              | Conditional | Approved clinic                  | Only if from listed country                                     |
| Criminal record certificate      | Conditional | Police authority                 | Only if working with vulnerable people                          |
| Bank statements (maintenance)    | Conditional | Applicant or sponsor             | £1,270 held for 28 consecutive days (unless sponsor is A-rated) |
| Academic qualifications          | Sometimes   | University/ECCTIS                | If job requires specific qualification                          |
| Biometric enrolment              | Mandatory   | UKVCAS appointment or VAC        | Photo + fingerprints                                            |
| ATAS certificate                 | Conditional | FCDO                             | Only for certain research roles                                 |

### Skilled Worker Visa — Decision Logic (Simplified)

> **Policy source:** [Immigration Rules Appendix Skilled Worker](https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-skilled-worker) · [Skilled Worker: salary requirements](https://www.gov.uk/skilled-worker-visa/your-job) · [Shortage Occupation List](https://www.gov.uk/government/publications/skilled-worker-visa-shortage-occupations/skilled-worker-visa-shortage-occupations) · [English language requirement](https://www.gov.uk/skilled-worker-visa/knowledge-of-english) · [General grounds for refusal (Part 9)](https://www.gov.uk/guidance/immigration-rules/immigration-rules-part-9-grounds-for-refusal)

```
START
│
├─ Is CoS valid and unspent?
│   ├─ NO → Request valid CoS / REFUSE
│   └─ YES ↓
│
├─ Is sponsor currently licensed?
│   ├─ NO → REFUSE (sponsor issue)
│   └─ YES ↓
│
├─ Does role meet skill level (RQF 3+)?
│   ├─ NO → REFUSE
│   └─ YES ↓
│
├─ Does salary meet threshold?
│   │   General: £38,700/yr OR going rate, whichever higher
│   │   New entrant: 70% of going rate (min £30,960)
│   │   Shortage Occupation: lower threshold applies
│   ├─ NO → REFUSE
│   └─ YES ↓
│
├─ English language requirement met?
│   │   CEFR B1 (speaking + listening) minimum
│   │   Exempt: national of majority-English-speaking country
│   │   Exempt: degree taught in English (with ECCTIS)
│   ├─ NO → Request evidence / REFUSE
│   └─ YES ↓
│
├─ Maintenance funds available?
│   │   £1,270 for 28 consecutive days
│   │   OR: A-rated sponsor certifies maintenance on CoS
│   ├─ NO → Request evidence / REFUSE
│   └─ YES ↓
│
├─ TB certificate required?
│   │   Check nationality against TB country list
│   ├─ Required and MISSING → Request / REFUSE
│   ├─ Required and PROVIDED → Verify, continue ↓
│   └─ Not required → continue ↓
│
├─ Criminal record check required?
│   │   Working with vulnerable groups?
│   ├─ Required and MISSING → Request / REFUSE
│   └─ Otherwise → continue ↓
│
├─ Any general grounds for refusal?
│   │   Previous immigration offences?
│   │   False representations?
│   │   Outstanding deportation order?
│   ├─ YES → REFUSE / REFER to senior caseworker
│   └─ NO ↓
│
└─ GRANT VISA
    Duration: up to 5 years (assigned on CoS)
    Conditions: no recourse to public funds (unless exception)
```

### Student Visa — Evidence Requirements

> **Policy source:** [Immigration Rules Appendix Student](https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-student) · [Student visa guidance](https://www.gov.uk/student-visa) · [Financial requirements (Appendix Finance)](https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-finance)

| Evidence                                     | Required?   | Source                                                       |
| -------------------------------------------- | ----------- | ------------------------------------------------------------ |
| Valid passport                               | Mandatory   | Applicant                                                    |
| Confirmation of Acceptance for Studies (CAS) | Mandatory   | Sponsor (university) — SMS system                            |
| Proof of English language                    | Mandatory   | CEFR B2 (degree), B1 (below degree)                          |
| Financial evidence                           | Mandatory   | £1,334/month (London) or £1,023/month (outside) for 9 months |
| TB test certificate                          | Conditional | If from listed country                                       |
| ATAS certificate                             | Conditional | Certain postgrad research subjects                           |
| Parental consent                             | Conditional | If applicant is 16-17                                        |
| Academic qualifications                      | Sometimes   | If referenced on CAS                                         |

### Student Visa — Decision Logic

> **Policy source:** [Immigration Rules Appendix Student](https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-student) · [Student visa: financial evidence](https://www.gov.uk/student-visa/money) · [Approved English language tests (SELTs)](https://www.gov.uk/guidance/prove-your-english-language-abilities-with-a-secure-english-language-test-selt)

```
START
│
├─ Is CAS valid, unspent, and assigned within last 6 months?
│   ├─ NO → REFUSE
│   └─ YES ↓
│
├─ Is sponsor (education provider) currently licensed + A-rated?
│   ├─ NO → REFUSE
│   └─ YES ↓
│
├─ Does course meet minimum level? (RQF 3 for adults, exceptions for child students)
│   ├─ NO → REFUSE
│   └─ YES ↓
│
├─ Academic progression: is this a higher level than previous course?
│   │   Exception: complementary course, intercalation
│   ├─ NO (and no valid exception) → REFUSE
│   └─ YES ↓
│
├─ English language met?
│   │   SELT test at CEFR B2+ (degree) or B1 (below degree)
│   │   OR: national of majority-English-speaking country
│   │   OR: previous degree taught in English
│   ├─ NO → REFUSE
│   └─ YES ↓
│
├─ Financial requirement met?
│   │   Tuition fees (outstanding amount on CAS) + living costs
│   │   London: £1,334/month × 9 (or course length)
│   │   Outside: £1,023/month × 9 (or course length)
│   │   Must hold for 28 consecutive days
│   ├─ NO → REFUSE
│   └─ YES ↓
│
├─ TB certificate (if required)?
│   ├─ Missing → REFUSE
│   └─ OK ↓
│
├─ ATAS (if required for subject)?
│   ├─ Missing → REFUSE
│   └─ OK ↓
│
├─ General grounds for refusal check
│   ├─ FAIL → REFUSE / REFER
│   └─ PASS ↓
│
└─ GRANT VISA
```

### Family Visa (Spouse/Partner) — Evidence & Decision Logic

> **Policy source:** [Immigration Rules Appendix FM (Family Members)](https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-fm-family-members) · [Family visa guidance](https://www.gov.uk/uk-family-visa) · [Financial requirement (Appendix FM-SE for self-employment)](https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-fm-se-family-members-specified-evidence) · [Adequate accommodation guidance](https://www.gov.uk/government/publications/chapter-8-appendix-fm-family-members) · [Article 8 ECHR guidance](https://www.gov.uk/government/publications/family-life-as-a-partner-or-parent-private-life-and-exceptional-circumstances)

This is the **most complex** mainstream visa. Huge subjectivity.

| Evidence                               | Required?   | Notes                                                           |
| -------------------------------------- | ----------- | --------------------------------------------------------------- |
| Valid passport                         | Mandatory   |                                                                 |
| Marriage/civil partnership certificate | Mandatory   | Or evidence of 2+ years cohabitation                            |
| Relationship evidence                  | Mandatory   | Photos, messages, travel records, joint finances                |
| Financial requirement (sponsor)        | Mandatory   | £29,000/yr income (from April 2024), or cash savings of £62,500 |
| English language (CEFR A1)             | Mandatory   | For entry; A2 for extension; B1 for settlement                  |
| Accommodation proof                    | Mandatory   | Not overcrowded per Housing Act standards                       |
| TB test                                | Conditional | If from listed country                                          |

```
START
│
├─ Is the relationship genuine and subsisting?
│   │   Evidence: comms history, photos, visits, cohabitation
│   │   This is the most subjective test. Interview may be needed.
│   ├─ INSUFFICIENT EVIDENCE → Request more / REFUSE
│   └─ SATISFIED ↓
│
├─ Financial requirement met?
│   │   Category A: £29,000 gross income for 6 months pre-application
│   │   Category B: £29,000 income in 12 months pre-application
│   │   Category C: cash savings of ≥ £62,500 above £16,000
│   │   Can combine employment, self-employment, pension, rental
│   ├─ NO → REFUSE
│   └─ YES ↓
│
├─ English language A1?
│   ├─ NO → REFUSE
│   └─ YES ↓
│
├─ Adequate accommodation?
│   │   Not overcrowded, exclusive use by family
│   ├─ NO → REFUSE
│   └─ YES ↓
│
├─ TB certificate (if required)?
│   ├─ Missing → REFUSE
│   └─ OK ↓
│
├─ General grounds for refusal?
│   ├─ FAIL → REFUSE / REFER
│   └─ PASS ↓
│
├─ If refused on rules, consider Article 8 ECHR
│   │   Exceptional circumstances / compelling compassionate factors?
│   │   THIS REQUIRES SENIOR CASEWORKER REVIEW
│   ├─ Grant outside rules (exceptional) ↓
│   └─ Maintain refusal
│
└─ GRANT VISA (30 months initial, path to ILR at 5 years)
```

---

## Part 3: Next-Action Logic (State Machine)

This is what your prototype should implement. Each case type has a predictable flow of **what happens next**.

### Generic Casework State Machine

```
                    ┌──────────────┐
                    │  SUBMITTED   │
                    └──────┬───────┘
                           │ auto-assign or manual
                    ┌──────▼───────┐
                    │   ASSIGNED   │
                    └──────┬───────┘
                           │ caseworker opens
                    ┌──────▼───────┐
              ┌─────│  IN_REVIEW   │─────┐
              │     └──────┬───────┘     │
              │            │             │
         evidence     all evidence    general grounds
         missing      received        concern
              │            │             │
     ┌────────▼──────┐     │      ┌──────▼──────────┐
     │   AWAITING    │     │      │   ESCALATED /   │
     │   EVIDENCE    │     │      │   REFERRED      │
     └────────┬──────┘     │      └──────┬──────────┘
              │            │             │
         evidence          │        senior decision
         received          │             │
              │            │             │
              └────────────▼─────────────┘
                    ┌──────▼───────┐
                    │  READY FOR   │
                    │  DECISION    │
                    └──────┬───────┘
                      ┌────┴────┐
                ┌─────▼──┐  ┌──▼──────┐
                │APPROVED│  │ REFUSED │
                └────────┘  └─────────┘
```

### Next-Action Logic per Status (what shows in "What you need to do")

| Current Status     | Trigger Condition                            | Generated Action                           | Action Type        | Priority                     |
| ------------------ | -------------------------------------------- | ------------------------------------------ | ------------------ | ---------------------------- |
| SUBMITTED          | Unassigned > 24 hours                        | "Assign to caseworker"                     | AUTO_ASSIGN        | HIGH                         |
| ASSIGNED           | Caseworker hasn't opened in 48h              | "Review new case"                          | REVIEW_DOCUMENTS   | MEDIUM                       |
| IN_REVIEW          | Evidence type X not received                 | "Chase [evidence type]"                    | CHASE_EVIDENCE     | Varies by deadline proximity |
| IN_REVIEW          | Evidence type X received but not reviewed    | "Review [evidence type]"                   | REVIEW_DOCUMENTS   | MEDIUM                       |
| AWAITING_EVIDENCE  | Evidence deadline passed                     | "Chase [evidence type] — [N] days overdue" | CHASE_EVIDENCE     | HIGH                         |
| AWAITING_EVIDENCE  | All evidence now received                    | "Move to full review"                      | REVIEW_DOCUMENTS   | HIGH                         |
| AWAITING_EVIDENCE  | > 28 days no response from applicant         | "Consider refusing for non-compliance"     | MAKE_DECISION      | HIGH                         |
| IN_REVIEW          | SLA deadline within 7 days                   | "Approaching SLA — prioritise decision"    | MAKE_DECISION      | URGENT                       |
| IN_REVIEW          | SLA deadline passed                          | "SLA BREACHED — make decision or escalate" | ESCALATE           | URGENT                       |
| IN_REVIEW          | Risk score > 70                              | "Flag for senior review"                   | ESCALATE           | HIGH                         |
| IN_REVIEW          | All criteria pass                            | "Ready to approve — record decision"       | MAKE_DECISION      | MEDIUM                       |
| IN_REVIEW          | One or more criteria fail                    | "Ready to refuse — draft refusal notice"   | MAKE_DECISION      | MEDIUM                       |
| IN_REVIEW          | Family visa + relationship evidence marginal | "Schedule interview"                       | SCHEDULE_INTERVIEW | HIGH                         |
| READY_FOR_DECISION | Not decided within 48h                       | "Decision pending — complete"              | MAKE_DECISION      | HIGH                         |

### Risk Score Calculation (for team leader dashboard)

```
risk_score = 0

# Time pressure
if days_until_sla <= 0:    risk_score += 40  # SLA breached
elif days_until_sla <= 7:  risk_score += 25  # approaching
elif days_until_sla <= 14: risk_score += 10

# Evidence completeness
evidence_received_pct = received / total_required
if evidence_received_pct < 0.5:  risk_score += 20
elif evidence_received_pct < 0.8: risk_score += 10

# Case complexity
if case_type == FAMILY_VISA:    risk_score += 10
if case_type == SETTLEMENT:     risk_score += 10
if case_type == ASYLUM:         risk_score += 15

# Priority
if priority == URGENT: risk_score += 15
if priority == HIGH:   risk_score += 10

# Staleness (no activity)
if days_since_last_activity > 14: risk_score += 10
if days_since_last_activity > 28: risk_score += 20

# Cap at 100
risk_score = min(risk_score, 100)
```

---

## Part 4: Realistic Seed Data Scenarios

These are the cases that tell a story in your demo:

### Case 1: The Urgent Overdue (Visa — Skilled Worker)

- **Priya Sharma**, Indian national, Tier 2 Work Visa
- Submitted 12 Feb, SLA deadline 28 Mar (breached)
- 5/6 evidence received. Missing: sponsorship certificate (employer dragging feet)
- **Next action:** Chase employer for CoS. 28 days overdue.
- **Risk score:** 85 (SLA breached + missing evidence + high priority)

### Case 2: The Ready-to-Decide (Visa — Student)

- **Marco Rossi**, Italian national, Student visa
- All evidence received. CAS valid. Financials check out.
- Caseworker just hasn't pressed the button yet.
- **Next action:** "All checks pass — record approval decision"
- **Risk score:** 30 (low complexity, but 2 weeks since last activity)

### Case 3: The Complex Family Case

- **Aisha Hassan**, Sudanese national, Spouse visa
- Relationship evidence is thin — 6 months of WhatsApp messages, 2 photos, 1 visit
- Financial evidence from sponsor: self-employed, complex income, borderline £29k
- **Next action:** "Relationship evidence insufficient — schedule interview or request more"
- **Risk score:** 55 (high complexity, subjective assessment needed)

### Case 4: The Fresh Submission (Visa — Skilled Worker)

- **Chen Wei**, Chinese national, Skilled Worker
- Submitted today. Auto-assigned. No evidence reviewed yet.
- **Next action:** "Initial review — check CoS validity and begin evidence checklist"
- **Risk score:** 15 (new, within SLA, standard case)

### Case 5: The Near-SLA (Visa — Settlement/ILR)

- **James O'Brien**, Nigerian national (British citizen returning family)
- ILR application, 5 months into 6-month SLA
- Complex: 10 years of residency evidence to verify
- Most evidence received but 2 documents under review
- **Next action:** "SLA in 28 days — prioritise remaining document review"
- **Risk score:** 60 (approaching SLA, high complexity)

### Case 6: The Refusal in Progress

- **Olga Petrov**, Russian national, Visitor visa
- Previous overstay found in records. False statement on application.
- **Next action:** "Draft refusal notice — general grounds (false representation)"
- **Risk score:** 45 (decision is clear, just needs documenting)

---

## Part 5: What Makes This Generalizable (Judge Ammunition)

When the judges ask "why visa/immigration?", your answer:

> "Every casework system in government follows the same pattern: someone submits something, a person reviews it against criteria, they chase missing information, they make a decision. We built it for visa casework because the data is well-understood and relatable — but the data model works for DWP benefits assessments, HMRC compliance checks, or planning applications. The state machine is universal."

The entities (`Case`, `Evidence`, `Action`, `Policy`, `CaseNote`) map directly to:

| Visa/Immigration      | DWP Benefits            | HMRC Tax                   | Planning                           |
| --------------------- | ----------------------- | -------------------------- | ---------------------------------- |
| Visa application      | UC claim                | Tax enquiry                | Planning application               |
| Passport, CoS         | ID, tenancy, payslips   | Tax returns, invoices      | Site plans, surveys                |
| Immigration Rules     | UC regulations          | Tax legislation            | NPPF / local plan                  |
| Chase evidence letter | UC journal message      | Information notice         | Request amendments                 |
| Caseworker            | Work coach              | Compliance officer         | Planning officer                   |
| SLA (8 weeks)         | First payment (5 weeks) | Enquiry window (12 months) | 8 weeks (minor) / 13 weeks (major) |

---

## Part 6: Numbers for the "Impact Slide"

If judges ask about scale / impact:

- UK government employs ~500,000 civil servants. A significant proportion do some form of casework.
- UKVI alone processes **~8,500 visa decisions per working day**
- DWP UC: ~120,000 new claims per month
- HMCTS: ~4.4 million cases per year
- Average caseworker spends **60-70% of time on information gathering**, only 30-40% on actual decision-making (NAO reports, GDS research)
- A tool that saves 15 minutes per case across 8,500 daily visa decisions = **2,125 hours saved per day** = ~265 FTE equivalent

---

## Part 7: Deep Dive — DVLA Vehicle Changes (V5C)

_Source: GOV.UK — "Change vehicle details on a V5C registration certificate (log book)" and all linked guidance pages._

> **Primary references:**
>
> - [Change vehicle details on a V5C (main guide)](https://www.gov.uk/change-vehicle-details-registration-certificate)
> - [What evidence to give](https://www.gov.uk/change-vehicle-details-registration-certificate/what-evidence-to-give)
> - [How to update your V5C](https://www.gov.uk/change-vehicle-details-registration-certificate/how-to-tell-dvla)
> - [Change your vehicle's tax class](https://www.gov.uk/change-vehicle-tax-class)
> - [Vehicle registration (full guide)](https://www.gov.uk/vehicle-registration)

This is a **second complete casework domain** that maps perfectly onto the Challenge 3 pattern. It's entirely within DVLA (Driver and Vehicle Licensing Agency) at Swansea.

### Why This Is Good Casework Material

- **High volume**: DVLA holds records for ~40 million vehicles. Hundreds of thousands of V5C changes annually.
- **Multiple case types** with wildly different complexity — from a simple colour change to a structural modification requiring physical inspection.
- **Evidence-heavy**: every change type needs specific documents. Caseworkers must verify completeness.
- **Has a decision tree**: some changes are auto-approved, some need inspection, some result in the vehicle losing its registration number entirely.
- **Post-based process**: currently the citizen fills in a paper V5C and posts it to Swansea. Classic "PDF to digital" overlap with Challenge 1.
- **Multiple postal addresses**: different change types go to different DVLA addresses (SA99 1DZ vs SA99 1BA vs SA99 1ZZ). A caseworker routing nightmare.

---

### 7.1 Change Types and Their Complexity

> **Source:** [When you need to update your V5C](https://www.gov.uk/change-vehicle-details-registration-certificate) · [How to update your V5C — postal addresses](https://www.gov.uk/change-vehicle-details-registration-certificate/how-to-tell-dvla) · [Vehicle changes that affect tax](https://www.gov.uk/change-vehicle-tax-class)

| Change Type                                           | Complexity | Evidence Required                                                                       | May Need Inspection?          | Affects Tax Class?     | Postal Address             |
| ----------------------------------------------------- | ---------- | --------------------------------------------------------------------------------------- | ----------------------------- | ---------------------- | -------------------------- |
| **Colour**                                            | Trivial    | None beyond V5C section 1/7                                                             | No                            | No                     | SA99 1BA                   |
| **Engine number / CC**                                | Low-Medium | Receipt, manufacturer letter, insurance report, or garage confirmation                  | No                            | Yes (if CC changes)    | SA99 1DZ                   |
| **Fuel type** (e.g. petrol → electric)                | Medium     | Garage headed paper (conversion) or receipt (new engine)                                | Possibly (if structural)      | Yes                    | SA99 1DZ                   |
| **Seating capacity**                                  | Low        | Evidence of change                                                                      | No                            | Yes (buses)            | SA99 1DZ                   |
| **Weight** (goods vehicles)                           | Low-Medium | Plating certificate or design weight certificate                                        | No                            | Yes                    | SA99 1DZ                   |
| **Wheel plan**                                        | Medium     | Description + evidence                                                                  | Possibly                      | No                     | SA99 1BA                   |
| **Body type → Motor Caravan**                         | High       | V1006 checklist, interior/exterior photos meeting 4 categories + external features, V5C | Yes (DVLA may require)        | Possibly               | SA99 1BA                   |
| **Chassis/bodyshell/frame — like-for-like**           | High       | V627/1, V5C (or V62), donor V5C, receipt/invoice, 7+ photos                             | No (but DVLA validates)       | No                     | SA99 1ZZ (Kits & Rebuilds) |
| **Chassis/bodyshell/frame — structural modification** | Very High  | V627/3, MOT evidence, MSVA (motorcycles)                                                | Yes                           | Possibly               | SA99 1ZZ (Kits & Rebuilds) |
| **Electric conversion**                               | High       | V627/3 (counts as structural mod), MOT evidence                                         | Yes                           | Yes (fuel type change) | SA99 1ZZ (Kits & Rebuilds) |
| **VIN / chassis number / frame number**               | High       | Evidence of number, DVLA may re-stamp                                                   | Often (identity verification) | No                     | SA99 1ZZ                   |
| **Body type** (other)                                 | Medium     | Description based on external appearance                                                | Possibly                      | No                     | SA99 1BA                   |

---

### 7.2 Evidence Requirements by Change Type

> **Source:** [What evidence to give](https://www.gov.uk/change-vehicle-details-registration-certificate/what-evidence-to-give)

#### Engine Number / Cylinder Capacity Change

> **Source:** [Evidence for engine/CC change](https://www.gov.uk/change-vehicle-details-registration-certificate/what-evidence-to-give)
> Caseworker must receive ONE of:

- Receipt for replacement engine (must include engine number AND cc)
- Written evidence from manufacturer
- Inspection report provided for insurance purposes
- Written confirmation on headed paper from a garage (if change was before current owner)

#### Fuel Type Change

> **Source:** [Evidence for fuel type change](https://www.gov.uk/change-vehicle-details-registration-certificate/what-evidence-to-give) · [Structurally modified vehicles (electric conversion)](https://www.gov.uk/vehicle-registration/structurally-modified-vehicles)

- **Existing engine converted**: confirmation on headed paper from garage that did the work
- **New engine fitted**: receipt for engine
- **Electric conversion**: triggers the structural modification pathway (see below)

#### Chassis / Bodyshell / Frame — Like-for-Like Replacement (Repair/Restoration)

> **Source:** [Repairs and restorations](https://www.gov.uk/vehicle-registration/repairs-restorations) · [Evidence for chassis/bodyshell/frame change](https://www.gov.uk/change-vehicle-details-registration-certificate/what-evidence-to-give) · [V627/1 Vehicle Parts Statement (form)](https://www.gov.uk/government/publications/vehicle-parts-statement-v6271) · [V62 application for V5C](https://www.gov.uk/government/publications/application-for-a-vehicle-registration-certificate) · [Vehicle identification number (VIN)](https://www.gov.uk/vehicle-registration/vehicle-identification-number)
> All of the following:

- V5C (or V62 application if V5C not available)
- Form V627/1 (Vehicle Parts Statement)
- V5C of the donor vehicle (if using second-hand parts, not new)
- Invoice/receipt including specification of replacement chassis (original or photocopy)
- **Photos (all required):**
  - Whole vehicle: front, back, sides, interior, registration plate
  - Engine number
  - VIN stamp/plate on OLD chassis being replaced
  - Old VIN sticker (near driver's door or dashboard windscreen-side)

#### Chassis / Bodyshell / Frame — Structural Modification

> **Source:** [Structurally modified vehicles](https://www.gov.uk/vehicle-registration/structurally-modified-vehicles) · [V627/3 Modified Vehicle Statement (form)](https://www.gov.uk/government/publications/modified-vehicle-statement-v6273) · [Motorcycle Single Vehicle Approval (MSVA)](https://www.gov.uk/vehicle-approval/motorcycle-single-vehicle-approval) · [What counts as structural modification (INF318)](https://www.gov.uk/government/publications/making-changes-to-a-vehicle-and-registering-kit-built-kit-converted-and-reconstructed-classic-vehicles-inf318)
> All of the following:

- Form V627/3 (Modified Vehicle Statement) — includes reg number and details of modification
- Evidence of current MOT (if vehicle requires one)
- MSVA certificate (Motorcycle Single Vehicle Approval) — if motorcycle
- If vehicle is over 40 years old: proof of MOT since the modification was made

#### Motor Caravan (Van → Campervan) Conversion

> **Source:** [Converting a vehicle into a motor caravan — body type & external features](https://www.gov.uk/government/publications/converting-a-vehicle-into-a-motor-caravan/converting-a-vehicle-into-a-motor-caravan) · [Internal features for motor caravans](https://www.gov.uk/government/publications/registering-a-diy-caravan/converting-a-vehicle-into-a-motorhome) · [V1006 Motor Caravan Conversion Checklist (PDF)](https://assets.publishing.service.gov.uk/media/5da87d72e5274a5cac4214f5/v1006-motor-caravan-conversion-checklist.pdf)

Must meet ALL three requirements:

**Requirement 1 — Eligible starting body type** (from V5C field D.5):
Ambulance, Box Van, Goods, Insulated Van, Light Goods, Light Van, Livestock Carrier, Luton Van, Minibus, MPV, Panel Van, Specially Fitted Van, Special Mobile Unit, Van with Side Windows.

> If body type is not on this list → REJECT immediately, do not process.

**Requirement 2 — External permanent features** (all required):

- 2+ windows on at least one side of main body (excludes driver/passenger doors)
- Separate door providing access to living accommodation (excludes driver/passenger doors; window on this door counts as a side window)
- Motor caravan-style graphics on both sides
- Awning bar attached to either side
- High-top roof (pop-top/elevating roof does NOT qualify)

**Requirement 3 — Internal features (all 4 categories required):**

| Category         | Requirement                                                                                                                                                             | Fixings          |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| 1. Seats & Table | Integral to living area, mounted independently. Table mounting permanently secured (top may be detachable). Seating fixed to floor or sidewall and usable at the table. | Rigid, permanent |
| 2. Sleeping      | Integral to living area. Can be beds or seat-beds. Base secured to floor or sidewall (unless over cab).                                                                 | Permanent        |
| 3. Cooking       | Minimum single ring or microwave. Secured to floor or sidewall. Gas supply: reservoir in secured cupboard OR pipe permanently fixed to vehicle structure.               | Permanent        |
| 4. Storage       | Cupboard or locker, integral to living area, mounted independently (unless below seat/bed/cooker). Secured to floor or sidewall (unless over cab).                      | Permanent        |

**Evidence to submit:**

- Completed V1006 Motor Caravan Conversion Checklist
- V5C showing eligible body type
- Interior photos of each feature (bed and table in use position), showing 2+ windows providing daylight into living accommodation
- Exterior photos: front, both sides, rear — registration plates clearly visible
- Photo of VIN/chassis number stamp
- Write description, date, and reg number on back of each photo

**What happens:** DVLA may also require a physical inspection (at DVLA's cost, but transport costs on the applicant). If the vehicle cannot be inspected, the application is refused.

---

### 7.3 Decision Logic — Master Routing Tree

> **Sources:** Synthesised from all GOV.UK pages listed above. Key routing logic from [How to update your V5C](https://www.gov.uk/change-vehicle-details-registration-certificate/how-to-tell-dvla) (postal addresses), [Repairs and restorations](https://www.gov.uk/vehicle-registration/repairs-restorations) (like-for-like path), [Structurally modified vehicles](https://www.gov.uk/vehicle-registration/structurally-modified-vehicles) (modification path), ['Q' registration numbers](https://www.gov.uk/vehicle-registration/q-registration-numbers) (identity-in-doubt path), [Type approval](https://www.gov.uk/vehicle-approval) (Q-reg prerequisite), and [Reconstructed classic vehicles](https://www.gov.uk/vehicle-registration/reconstructed-classic-vehicles) (classic path + [vehicle owners' clubs list](https://www.gov.uk/government/publications/list-of-vehicle-owner-clubs)).

```
VEHICLE CHANGE APPLICATION RECEIVED
│
├─ What type of change?
│
├── [COLOUR ONLY]
│    └─ Update V5C field → Issue new V5C (2-4 weeks) → DONE
│
├── [ENGINE / CC / FUEL / SEATS / WEIGHT]
│    ├─ Evidence provided?
│    │   ├─ NO → REJECT (return V5C, request evidence)
│    │   └─ YES → Verify evidence against criteria
│    │       ├─ Evidence sufficient → Update V5C, assess tax implications
│    │       │   ├─ Tax class affected? → Notify keeper of new tax rate
│    │       │   └─ Tax class unchanged → Issue new V5C → DONE
│    │       └─ Evidence insufficient → REQUEST more evidence
│    │
│    └─ Route to: SA99 1DZ
│
├── [WHEEL PLAN / BODY TYPE / VIN / CHASSIS NUMBER / FRAME NUMBER]
│    ├─ Evidence provided?
│    │   ├─ NO → REJECT
│    │   └─ YES → Verify evidence
│    │       ├─ DVLA determines inspection needed?
│    │       │   ├─ YES → Schedule DVLA inspection
│    │       │   │   ├─ PASS → Update V5C → DONE
│    │       │   │   └─ FAIL → REFUSE application
│    │       │   └─ NO → Update V5C → DONE
│    │       └─ Evidence insufficient → REQUEST more
│    │
│    └─ Route to: SA99 1BA
│
├── [BODY TYPE → MOTOR CARAVAN]
│    ├─ Current body type on eligible list?
│    │   ├─ NO → REJECT (do not process)
│    │   └─ YES ↓
│    ├─ V1006 checklist complete?
│    │   ├─ NO → REJECT
│    │   └─ YES ↓
│    ├─ Exterior photos show all 5 external features?
│    │   ├─ NO → REJECT / REQUEST better photos
│    │   └─ YES ↓
│    ├─ Interior photos show all 4 categories?
│    │   ├─ NO → REJECT / REQUEST better photos
│    │   └─ YES ↓
│    ├─ DVLA determines inspection needed?
│    │   ├─ YES → Schedule inspection
│    │   │   ├─ Vehicle can attend → INSPECT
│    │   │   │   ├─ PASS → Change body type → Issue new V5C → DONE
│    │   │   │   └─ FAIL → REFUSE
│    │   │   └─ Vehicle cannot attend → REFUSE
│    │   └─ NO → Change body type → Issue new V5C → DONE
│    │
│    └─ Route to: SA99 1BA
│
├── [CHASSIS / BODYSHELL / FRAME — LIKE-FOR-LIKE REPLACEMENT]
│    ├─ V627/1 provided?
│    │   ├─ NO → REJECT
│    │   └─ YES ↓
│    ├─ V5C (or V62) provided?
│    │   ├─ NO → REJECT
│    │   └─ YES ↓
│    ├─ Using second-hand parts from another vehicle?
│    │   ├─ YES → Donor V5C provided?
│    │   │   ├─ NO → REJECT
│    │   │   └─ YES ↓
│    │   │   └─ Donor vehicle has Certificate of Destruction?
│    │   │       ├─ YES → REJECT (CoD vehicles cannot provide major parts)
│    │   │       └─ NO → OK ↓
│    │   └─ NO (new parts) → OK ↓
│    ├─ Receipt/invoice with chassis spec?
│    │   ├─ NO → REJECT
│    │   └─ YES ↓
│    ├─ All required photos present? (vehicle exterior, engine no, old VIN stamp, old VIN sticker)
│    │   ├─ NO → REJECT / REQUEST
│    │   └─ YES ↓
│    ├─ VIN can be verified on old chassis?
│    │   ├─ YES → DVLA issues authorisation letter to restamp VIN on new chassis
│    │   │   └─ Confirmation of restamp received → Issue new V5C → DONE
│    │   └─ NO (identity in doubt) → Issue Q-registration number
│    │       └─ Vehicle must pass type approval → Q-plate issued → DONE
│    │
│    └─ Route to: SA99 1ZZ (Kits & Rebuilds, D10)
│
├── [STRUCTURAL MODIFICATION (inc. electric conversion)]
│    ├─ V627/3 provided?
│    │   ├─ NO → REJECT
│    │   └─ YES ↓
│    ├─ V5C provided?
│    │   ├─ NO → REJECT
│    │   └─ YES ↓
│    ├─ MOT evidence provided? (mandatory if vehicle > 40 years old)
│    │   ├─ NO (and required) → REJECT
│    │   └─ YES / not required ↓
│    ├─ Is it a motorcycle → tricycle conversion?
│    │   ├─ YES, used conversion kit/plan → Redirect to kit-converted vehicle process
│    │   ├─ YES, no kit, welded tricycle → Needs new VIN + MSVA
│    │   └─ NO ↓
│    ├─ MSVA needed? (motorcycles)
│    │   ├─ YES and not provided → REJECT
│    │   └─ YES and provided / not needed ↓
│    ├─ DVLA reviews modification details
│    │   ├─ VIN can be retained → Issue new V5C marked "modified from original spec" → DONE
│    │   └─ Age/identity in doubt → Issue Q-registration
│    │       └─ Vehicle must pass type approval → DONE
│    │
│    └─ Route to: SA99 1ZZ (Kits & Rebuilds, D10)
│
└── [RECONSTRUCTED CLASSIC VEHICLE]
     ├─ All parts genuine period components, 25+ years old, same spec?
     │   ├─ NO (replica/new parts) → Q-registration path
     │   └─ YES ↓
     ├─ Vehicle owners' club written report confirming:
     │   - Vehicle inspected ✓
     │   - True reflection of marque ✓
     │   - All components genuine period, 25+ years old ✓
     │   - Manufacture dates for major components provided ✓
     │   ├─ NO → REJECT
     │   └─ YES ↓
     ├─ V627/1 provided?
     │   ├─ NO → REJECT
     │   └─ YES ↓
     ├─ Receipts for parts?
     │   ├─ NO → REJECT
     │   └─ YES ↓
     └─ DVLA assigns age-related registration (based on youngest component) → DONE
```

---

### 7.4 Next-Action Logic for DVLA Vehicle Change Cases

| Current Status      | Trigger Condition                                            | Generated Action                                                                | Priority |
| ------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------- | -------- |
| RECEIVED            | Application not triaged in 24h                               | "Triage new application — classify change type"                                 | MEDIUM   |
| RECEIVED            | Missing V5C section 1/7 completion                           | "Application incomplete — return to keeper"                                     | HIGH     |
| TRIAGED             | Change type = colour only                                    | "Auto-process colour change — issue new V5C"                                    | LOW      |
| TRIAGED             | Change type = engine/CC/fuel/seats/weight                    | "Route to SA99 1DZ team — verify evidence"                                      | MEDIUM   |
| TRIAGED             | Change type = body type / wheel plan / VIN                   | "Route to SA99 1BA team — may need inspection"                                  | MEDIUM   |
| TRIAGED             | Change type = chassis/structural/kits                        | "Route to Kits & Rebuilds (SA99 1ZZ)"                                           | MEDIUM   |
| TRIAGED             | Change type = motor caravan conversion                       | "Check eligible body type before processing"                                    | HIGH     |
| IN_REVIEW           | Motor caravan — body type not on eligible list               | "REJECT — body type [X] not eligible for conversion. Return V5C."               | HIGH     |
| IN_REVIEW           | Evidence missing for change type                             | "Return to keeper — request [specific missing document]"                        | MEDIUM   |
| IN_REVIEW           | Photos missing or inadequate                                 | "Request clearer photos — [specify which: VIN stamp / exterior / interior]"     | MEDIUM   |
| IN_REVIEW           | Motor caravan — all evidence + photos satisfactory           | "Assess whether inspection required"                                            | MEDIUM   |
| IN_REVIEW           | Chassis replacement — donor vehicle has CoD                  | "REJECT — donor vehicle has Certificate of Destruction, cannot use major parts" | HIGH     |
| INSPECTION_REQUIRED | Inspection not yet scheduled                                 | "Schedule DVLA inspection — contact keeper with location and date"              | HIGH     |
| INSPECTION_REQUIRED | Inspection scheduled, awaiting result                        | "Awaiting inspection report"                                                    | MEDIUM   |
| INSPECTION_COMPLETE | Inspection passed                                            | "Update vehicle record, issue new V5C"                                          | HIGH     |
| INSPECTION_COMPLETE | Inspection failed                                            | "Draft refusal notice — inspection fail reasons: [X]"                           | HIGH     |
| IN_REVIEW           | VIN cannot be verified / identity in doubt                   | "Initiate Q-registration process — vehicle needs type approval"                 | HIGH     |
| IN_REVIEW           | All checks pass, no inspection needed                        | "Approve change — issue new V5C"                                                | MEDIUM   |
| IN_REVIEW           | Change affects tax class (engine CC / fuel / weight / seats) | "Notify keeper of tax implications before issuing V5C"                          | HIGH     |
| IN_REVIEW           | Structural mod — vehicle >40 years, no MOT evidence          | "Request MOT evidence — mandatory for vehicles over 40 years"                   | HIGH     |
| IN_REVIEW           | Chassis like-for-like approved                               | "Issue restamp authorisation letter to keeper"                                  | HIGH     |
| RESTAMP_AUTHORISED  | Keeper hasn't confirmed restamp in 28 days                   | "Chase keeper — confirm VIN restamping complete"                                | MEDIUM   |
| RESTAMP_CONFIRMED   | Restamp confirmed                                            | "Issue new V5C with original VIN retained"                                      | MEDIUM   |
| DECIDED             | V5C not despatched in 2 weeks                                | "Escalate — V5C production/despatch delay"                                      | HIGH     |
| DECIDED             | 4+ weeks since decision, keeper hasn't received V5C          | "Investigate — replacement V5C may be needed"                                   | HIGH     |

---

### 7.5 DVLA Case Statuses (State Machine)

```
                     ┌──────────────┐
                     │   RECEIVED   │
                     └──────┬───────┘
                            │ classify change type
                     ┌──────▼───────┐
              ┌──────│   TRIAGED    │──────┐
              │      └──────┬───────┘      │
              │             │              │
         auto-process   needs review   incomplete
         (colour)           │          (return to keeper)
              │             │              │
       ┌──────▼──┐   ┌─────▼──────┐  ┌────▼────────────┐
       │APPROVED │   │ IN_REVIEW  │  │ RETURNED_TO_     │
       └─────────┘   └─────┬──────┘  │ KEEPER           │
                      ┌─────┼─────┐  └────┬─────────────┘
                      │     │     │       │
                   pass  inspect  fail   resubmitted
                      │     │     │       │
                      │  ┌──▼────────┐    │
                      │  │INSPECTION │    │
                      │  │REQUIRED   │    │
                      │  └──┬────────┘    │
                      │   ┌─┴──┐          │
                      │ pass  fail        │
                      │   │    │          │
                      │   │  ┌─▼────┐     │
                      │   │  │REFUSED│    │
                      │   │  └──────┘     │
                      │   │               │
              ┌───────▼───▼──┐            │
              │  APPROVED    │◄───────────┘
              └──────┬───────┘
                     │
          ┌──────────┼──────────┐
          │          │          │
     ┌────▼────┐ ┌───▼─────┐ ┌─▼──────────┐
     │ ISSUE   │ │ RESTAMP │ │ Q-REG      │
     │ NEW V5C │ │ AUTH'D  │ │ PROCESS    │
     └────┬────┘ └───┬─────┘ └─┬──────────┘
          │          │          │
          │     confirmed      type approval
          │          │          │
          │    ┌─────▼────┐    │
          │    │RESTAMP    │    │
          │    │CONFIRMED  │    │
          │    └─────┬─────┘   │
          │          │         │
          └──────────▼─────────┘
                     │
              ┌──────▼───────┐
              │  V5C ISSUED  │
              └──────────────┘
```

---

### 7.6 Seed Data Scenarios — DVLA Vehicle Changes

#### Case V5C-001: The Trivial Colour Change

- **Keeper:** Dave Mitchell, Swindon
- **Vehicle:** 2019 Ford Focus, reg AB19 CDE, currently registered as Blue
- Changed to Red. Filled in V5C section 1, posted to SA99 1BA.
- **Status:** TRIAGED → auto-process
- **Next action:** "Colour change only — issue new V5C"
- **Risk score:** 5 (trivial, no evidence needed)

#### Case V5C-002: Engine Swap — Missing Evidence

- **Keeper:** Karen Patel, Birmingham
- **Vehicle:** 2016 VW Golf, posted V5C to SA99 1DZ claiming new engine (1.4L → 2.0L)
- **Policy ref:** [Evidence for engine/CC change](https://www.gov.uk/change-vehicle-details-registration-certificate/what-evidence-to-give)
- No receipt or manufacturer confirmation attached.
- **Status:** IN_REVIEW
- **Next action:** "Return to keeper — request receipt for replacement engine including engine number and cylinder capacity"
- **Risk score:** 30 (straightforward but blocked on evidence)

#### Case V5C-003: Van → Campervan Conversion (Complex)

- **Keeper:** Steve & Lisa Carter, Bristol
- **Vehicle:** 2017 Peugeot Boxer Panel Van, converting to motor caravan
- **Policy ref:** [Motor caravan external features](https://www.gov.uk/government/publications/converting-a-vehicle-into-a-motor-caravan/converting-a-vehicle-into-a-motor-caravan) · [Internal features](https://www.gov.uk/government/publications/registering-a-diy-caravan/converting-a-vehicle-into-a-motorhome)
- Submitted V5C + V1006 checklist + photos.
- Body type is "Panel Van" — eligible ✓
- Exterior photos show: windows ✓, separate door ✓, graphics ✓, awning bar ✓... but the roof is a pop-top elevating roof ✗ (does NOT qualify — must be a permanent high-top).
- **Status:** IN_REVIEW
- **Next action:** "REJECT — roof type does not meet requirements. Pop-top/elevating roof not accepted; permanent high-top required."
- **Risk score:** 45 (applicant will likely resubmit or appeal)

#### Case V5C-004: Chassis Replacement — Classic Car Restoration

- **Keeper:** Martin Hughes, Hereford
- **Vehicle:** 1972 MGB GT, classic car, chassis rusted through
- Replacing chassis like-for-like with new Heritage shell (same dimensions and appearance)
- **Policy ref:** [Repairs and restorations](https://www.gov.uk/vehicle-registration/repairs-restorations) · [V627/1 form](https://www.gov.uk/government/publications/vehicle-parts-statement-v6271)
- Submitted: V627/1 ✓, V5C ✓, receipt from Heritage Bodyshells ✓, photos of old VIN stamp ✓, photos of vehicle ✓
- **Status:** IN_REVIEW → All evidence complete
- **Next action:** "Issue VIN restamp authorisation letter to keeper"
- **Risk score:** 25 (standard restoration, good evidence)

#### Case V5C-005: Electric Conversion — Structural Modification

- **Keeper:** James Park, Edinburgh
- **Vehicle:** 1989 Land Rover Defender, converting from diesel to electric
- Counts as structural modification (electric conversion) regardless of whether chassis was altered.
- **Policy ref:** [Structurally modified vehicles — electric conversion](https://www.gov.uk/vehicle-registration/structurally-modified-vehicles) · [V627/3 form](https://www.gov.uk/government/publications/modified-vehicle-statement-v6273)
- Submitted: V627/3 ✓, V5C ✓, MOT evidence ✓ (vehicle is >40 years old so MOT proof mandatory)
- **Status:** IN_REVIEW → Evidence complete, inspection likely needed
- **Next action:** "Schedule DVLA inspection — electric conversion of pre-1986 vehicle"
- **Risk score:** 50 (inspection pending, moderate complexity)
- **Tax impact:** Fuel type changing from diesel to electric — will affect tax class.

#### Case V5C-006: Motorcycle Frame Change — Missing MSVA

- **Keeper:** Ryan Cooper, Manchester
- **Vehicle:** 2005 Honda CB600F, modified frame (welded hardtail conversion — structural mod)
- **Policy ref:** [Structurally modified vehicles](https://www.gov.uk/vehicle-registration/structurally-modified-vehicles) · [MSVA](https://www.gov.uk/vehicle-approval/motorcycle-single-vehicle-approval)
- Submitted V627/3 ✓, V5C ✓... but no MSVA certificate.
- This is a structural modification to a motorcycle frame → MSVA may be required.
- **Status:** IN_REVIEW
- **Next action:** "Request MSVA certificate — structural modification to motorcycle frame requires Motorcycle Single Vehicle Approval"
- **Risk score:** 40 (blocked on evidence, but clear path forward)

#### Case V5C-007: Reconstructed Classic — Identity in Doubt

- **Keeper:** Tony Greer, Norfolk
- **Vehicle:** Claimed 1965 Jaguar E-Type, assembled from parts of multiple vehicles
- Vehicle owner's club report says: 3 of 5 major components verified as genuine period parts. 2 components appear to be modern reproductions.
- **Policy ref:** [Reconstructed classic vehicles](https://www.gov.uk/vehicle-registration/reconstructed-classic-vehicles) · ['Q' registration numbers](https://www.gov.uk/vehicle-registration/q-registration-numbers) · [Vehicle owners' clubs list](https://www.gov.uk/government/publications/list-of-vehicle-owner-clubs)
- **Status:** IN_REVIEW
- **Next action:** "Cannot issue age-related registration — replica parts present. Initiate Q-registration pathway. Vehicle must pass type approval."
- **Risk score:** 60 (complex, keeper will be unhappy about losing original-era registration)

---

### 7.7 Forms Reference

> **Source:** Links to official DVLA form publications on GOV.UK.

| Form                      | Name                               | When Used                                                                  | Link                                                                                                                                                                        |
| ------------------------- | ---------------------------------- | -------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **V5C** (sections 1 or 7) | Registration Certificate           | Always — the base document for any change                                  | [About V5C](https://www.gov.uk/vehicle-log-book)                                                                                                                            |
| **V62**                   | Application for V5C                | When V5C is lost/unavailable                                               | [V62 form](https://www.gov.uk/government/publications/application-for-a-vehicle-registration-certificate)                                                                   |
| **V627/1**                | Vehicle Parts Statement            | Like-for-like chassis/bodyshell/frame replacement (repairs & restorations) | [V627/1 form](https://www.gov.uk/government/publications/vehicle-parts-statement-v6271)                                                                                     |
| **V627/3**                | Modified Vehicle Statement         | Structural modifications (inc. electric conversion)                        | [V627/3 form](https://www.gov.uk/government/publications/modified-vehicle-statement-v6273)                                                                                  |
| **V1006**                 | Motor Caravan Conversion Checklist | Van → campervan body type change                                           | [V1006 checklist (PDF)](https://assets.publishing.service.gov.uk/media/5da87d72e5274a5cac4214f5/v1006-motor-caravan-conversion-checklist.pdf)                               |
| **INF318**                | Making changes to a vehicle        | Defines what counts as repair vs structural modification                   | [INF318 guidance](https://www.gov.uk/government/publications/making-changes-to-a-vehicle-and-registering-kit-built-kit-converted-and-reconstructed-classic-vehicles-inf318) |

### 7.8 Postal Routing

> **Source:** [How to update your V5C — where to send](https://www.gov.uk/change-vehicle-details-registration-certificate/how-to-tell-dvla) · [Kits and Rebuilds address from Repairs and restorations](https://www.gov.uk/vehicle-registration/repairs-restorations)

| Destination               | Address                                         | Change Types                                                                                                |
| ------------------------- | ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **General changes**       | DVLA, Swansea, SA99 1BA                         | Colour, body type, wheel plan, VIN changes, motor caravan conversion                                        |
| **Tax-affecting changes** | DVLA, Swansea, SA99 1DZ                         | Engine size (CC), fuel type, weight, seats                                                                  |
| **Kits & Rebuilds**       | Kits and Rebuilds, D10, DVLA, Swansea, SA99 1ZZ | Chassis/bodyshell/frame replacement, structural modifications, electric conversions, reconstructed classics |

---

### 7.9 Why This Maps Perfectly to Your Data Model

| Your Existing Entity | DVLA Equivalent                                                                                                                                                                    |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Case`               | V5C change application                                                                                                                                                             |
| `CaseType`           | `COLOUR_CHANGE`, `ENGINE_CHANGE`, `BODY_TYPE_CHANGE`, `MOTOR_CARAVAN_CONVERSION`, `CHASSIS_REPLACEMENT`, `STRUCTURAL_MODIFICATION`, `ELECTRIC_CONVERSION`, `RECONSTRUCTED_CLASSIC` |
| `CaseStatus`         | RECEIVED → TRIAGED → IN_REVIEW → (INSPECTION_REQUIRED → INSPECTION_COMPLETE) → APPROVED/REFUSED → V5C_ISSUED                                                                       |
| `Evidence`           | V5C, V627/1, V627/3, V1006, receipts, photos (VIN, exterior, interior), MOT cert, MSVA cert, owner's club report                                                                   |
| `Action`             | Chase missing evidence, schedule inspection, issue restamp letter, notify tax change, draft refusal                                                                                |
| `Policy`             | Motor caravan conversion rules (body type eligibility, 4 internal categories, 5 external features), structural mod definition, CoD restrictions                                    |
| `CaseNote`           | "Returned to keeper — missing receipt", "Inspection passed", "Q-registration initiated — identity in doubt"                                                                        |

This proves your model is domain-agnostic. Swap the enums, seed different data, same dashboard works.
