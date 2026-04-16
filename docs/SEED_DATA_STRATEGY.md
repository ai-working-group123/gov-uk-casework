---

## Seed Data Strategy

Generate with Copilot in the first 30 minutes. The seed data must tell a **story**:

### Required Personas in Seed Data

| Caseworker | Cases | Story |
|------------|-------|-------|
| Sarah Chen | 12 | Experienced, manageable load, 1 overdue case |
| Fatima Ali | 15 | Overloaded, 3 overdue, needs help |
| David Park | 9 | Mid-range, all on track |
| Tom Hughes | 5 | Light load, available for rebalancing |
| Nia Williams | 6 | Mid-range, 1 approaching SLA |

### Required Cases for Demo

| Reference | Applicant | Type | Status | Story |
|-----------|-----------|------|--------|-------|
| VIS-2024-00847 | Priya Sharma | Tier 2 Work | OVERDUE | Missing sponsorship cert, 13 days overdue — the "urgent" demo case |
| VIS-2024-00891 | Marco Rossi | Tier 4 Student | Action needed | Documents received, ready for review |
| VIS-2024-00902 | Aisha Hassan | Family Visa | On track | Everything progressing normally |
| VIS-2024-00923 | James O'Brien | Tier 4 Student | New | Just submitted today, assigned but not started |
| VIS-2024-00734 | Li Wei | Settlement | OVERDUE | Complex case, stuck in review for weeks |

### Volume

- **5 caseworkers** across 1 team
- **47 total cases** (matches dashboard numbers)
- **~6 evidence items per case** (some complete, some partially received)
- **200+ case notes** across all cases (gives realistic timelines)
- **~30 policy reference entries** (granular criteria, not just 1 per visa type)
- **~20 correspondence records** across active cases (chase letters, requests, notifications)

---

## Policy Reference Seed Data (Examples)

These are the entries that power the "why" behind every evidence request and action. Generate the full set with Copilot from the CHALLENGE_3_ANALYSIS.md decision trees.

### Skilled Worker Visa — Policy References

```ruby
skilled_worker_policies = [
  {
    code: "SW",
    parent_code: nil,
    title: "Skilled Worker Visa",
    policy_area: "Skilled Worker Visa",
    case_types: "tier2_work",
    summary: "Requirements for the Skilled Worker immigration route",
    criteria: "Valid CoS, licensed sponsor, skill level RQF 3+, salary threshold, English language, maintenance funds, TB cert (if applicable), no general grounds for refusal",
    govuk_url: "https://www.gov.uk/skilled-worker-visa",
    legislation_url: "https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-skilled-worker",
    applicant_summary: "The Skilled Worker visa lets you come to or stay in the UK to do an eligible job with an approved employer.",
    applicant_url: "https://www.gov.uk/skilled-worker-visa"
  },
  {
    code: "SW-COS-VALID",
    parent_code: "SW",
    title: "Certificate of Sponsorship must be valid and unspent",
    policy_area: "Skilled Worker Visa",
    case_types: "tier2_work",
    summary: "Applicant must have a valid, unspent CoS assigned by a licensed sponsor",
    criteria: "CoS must: be assigned to this applicant, not be used for a previous application, not be withdrawn, be from a currently licensed sponsor",
    govuk_url: "https://www.gov.uk/skilled-worker-visa/your-job",
    internal_guidance_url: nil,
    applicant_summary: "Your employer must give you a certificate of sponsorship (CoS) before you apply. This is a reference number, not a physical document.",
    applicant_url: "https://www.gov.uk/skilled-worker-visa/your-job"
  },
  {
    code: "SW-SALARY",
    parent_code: "SW",
    title: "Salary must meet the minimum threshold",
    policy_area: "Skilled Worker Visa",
    case_types: "tier2_work",
    summary: "General: £38,700/yr or going rate (whichever higher). New entrant: 70% of going rate (min £30,960).",
    criteria: "Check salary on CoS against: general threshold £38,700, occupation-specific going rate, new entrant rate if applicable, shortage occupation rate if listed",
    govuk_url: "https://www.gov.uk/skilled-worker-visa/your-job",
    legislation_url: "https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-skilled-worker",
    applicant_summary: "Your job must pay at least the minimum salary for your occupation. Your employer confirms your salary on the certificate of sponsorship.",
    applicant_url: "https://www.gov.uk/skilled-worker-visa/your-job"
  },
  {
    code: "SW-ENGLISH",
    parent_code: "SW",
    title: "English language requirement (CEFR B1)",
    policy_area: "Skilled Worker Visa",
    case_types: "tier2_work",
    summary: "Must prove English at CEFR B1 (speaking and listening). Exempt if from majority-English-speaking country or hold English-taught degree.",
    criteria: "Accepted proof: approved SELT at B1+, degree taught in English (with ECCTIS confirmation), nationality of majority-English-speaking country",
    govuk_url: "https://www.gov.uk/skilled-worker-visa/knowledge-of-english",
    applicant_summary: "You must prove you can read, write, speak and understand English to at least level B1 on the CEFR scale.",
    applicant_url: "https://www.gov.uk/skilled-worker-visa/knowledge-of-english"
  },
  {
    code: "SW-MAINTENANCE",
    parent_code: "SW",
    title: "Maintenance funds (financial requirement)",
    policy_area: "Skilled Worker Visa",
    case_types: "tier2_work",
    summary: "£1,270 held for 28 consecutive days, unless A-rated sponsor certifies maintenance on CoS",
    criteria: "Bank statements showing £1,270+ for 28 consecutive days ending within 31 days of application. OR: sponsor is A-rated and has certified maintenance on CoS (no applicant evidence needed).",
    govuk_url: "https://www.gov.uk/skilled-worker-visa/money",
    applicant_summary: "You need £1,270 in your bank account for 28 days in a row, unless your employer has confirmed they will support you.",
    applicant_url: "https://www.gov.uk/skilled-worker-visa/money"
  },
  {
    code: "SW-TB",
    parent_code: "SW",
    title: "TB test certificate (if from listed country)",
    policy_area: "Skilled Worker Visa",
    case_types: "tier2_work",
    summary: "Required only if applicant is from a country on the TB testing list",
    criteria: "Check nationality against TB country list. If listed: must provide certificate from approved clinic. Valid for 6 months from issue.",
    govuk_url: "https://www.gov.uk/tb-test-visa",
    applicant_summary: "If you're from a country where TB testing is required, you must get a test from an approved clinic before you apply.",
    applicant_url: "https://www.gov.uk/tb-test-visa/countries-where-you-need-a-tb-test"
  }
]

skilled_worker_policies.each { |attrs| PolicyReference.create!(attrs) }
```

### Motor Caravan Conversion — Policy References (DVLA example)

```ruby
motor_caravan_policies = [
  {
    code: "MC",
    parent_code: nil,
    title: "Motor Caravan Conversion",
    policy_area: "Motor Caravan Conversion",
    case_types: "motor_caravan_conversion",
    summary: "Requirements for changing V5C body type to motor caravan",
    criteria: "Eligible starting body type, external permanent features (5 checks), internal features (4 categories)",
    govuk_url: "https://www.gov.uk/government/publications/converting-a-vehicle-into-a-motor-caravan/converting-a-vehicle-into-a-motor-caravan",
    applicant_summary: "To change your vehicle's body type to motor caravan, it must meet specific external and internal feature requirements.",
    applicant_url: "https://www.gov.uk/government/publications/converting-a-vehicle-into-a-motor-caravan/converting-a-vehicle-into-a-motor-caravan"
  },
  {
    code: "MC-BODY-ELIGIBLE",
    parent_code: "MC",
    title: "Current body type must be on eligible list",
    policy_area: "Motor Caravan Conversion",
    case_types: "motor_caravan_conversion",
    summary: "V5C field D.5 must show one of 14 eligible body types (e.g. panel van, box van, light goods)",
    criteria: "Eligible: ambulance, box van, goods, insulated van, light goods, light van, livestock carrier, Luton van, minibus, MPV, panel van, specially fitted van, special mobile unit, van with side windows. If not on list: reject immediately.",
    govuk_url: "https://www.gov.uk/government/publications/converting-a-vehicle-into-a-motor-caravan/converting-a-vehicle-into-a-motor-caravan#current-body-type-shown-on-your-v5c-registration-certificate-log-book",
    applicant_summary: "Your vehicle's current body type (shown on your V5C log book) must be one of the types DVLA will consider for conversion.",
    applicant_url: "https://www.gov.uk/government/publications/converting-a-vehicle-into-a-motor-caravan/converting-a-vehicle-into-a-motor-caravan"
  },
  {
    code: "MC-EXT-ROOF",
    parent_code: "MC",
    title: "Must have a permanent high-top roof",
    policy_area: "Motor Caravan Conversion",
    case_types: "motor_caravan_conversion",
    summary: "A high-top roof is required. Pop-top / elevating roofs do NOT qualify.",
    criteria: "Roof must be a permanent high-top construction. Pop-top and elevating roofs are explicitly excluded.",
    govuk_url: "https://www.gov.uk/government/publications/converting-a-vehicle-into-a-motor-caravan/converting-a-vehicle-into-a-motor-caravan#motor-caravan-external-permanent-features",
    applicant_summary: "Your converted vehicle must have a fixed high-top roof. Pop-up or elevating roofs are not accepted.",
    applicant_url: "https://www.gov.uk/government/publications/converting-a-vehicle-into-a-motor-caravan/converting-a-vehicle-into-a-motor-caravan"
  },
  {
    code: "MC-INT-COOKING",
    parent_code: "MC",
    title: "Cooking facilities (Category 3)",
    policy_area: "Motor Caravan Conversion",
    case_types: "motor_caravan_conversion",
    summary: "Minimum single ring or microwave, permanently secured to floor or side wall",
    criteria: "At least a single ring cooking facility or microwave, secured directly to the vehicle floor or side wall. If gas-fuelled: reservoir in secured cupboard or pipe permanently fixed to vehicle structure.",
    govuk_url: "https://www.gov.uk/government/publications/registering-a-diy-caravan/converting-a-vehicle-into-a-motorhome#category-3-cooking-facilities",
    applicant_summary: "Your conversion must include a cooker (at least one ring) or microwave that's permanently fixed inside the vehicle.",
    applicant_url: "https://www.gov.uk/government/publications/registering-a-diy-caravan/converting-a-vehicle-into-a-motorhome"
  }
]

motor_caravan_policies.each { |attrs| PolicyReference.create!(attrs) }
```

---

## How Policy Citations Flow Through the UI

### Caseworker View — Evidence Panel

When a caseworker views a case, each evidence item now shows *why* it's required:

```
┌─ Evidence ───────────────────────────────────────────────┐
│                                                          │
│  ✅ Passport (valid)                                     │
│     Required by: SW — Skilled Worker Visa                │
│                                                          │
│  ❌ Sponsorship certificate                  ⚠️ 28d late │
│     Required by: SW-COS-VALID                            │
│     "CoS must be valid and unspent"                      │
│     📋 Appendix Skilled Worker →                         │
│     [Send chase letter]                                  │
│                                                          │
│  ✅ English language  (CEFR B1)                          │
│     Required by: SW-ENGLISH                              │
│     "CEFR B1 speaking and listening"                     │
│     📋 Knowledge of English →                            │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Caseworker View — Actions Panel

Each action shows the policy driving it and internal guidance:

```
┌─ What you need to do ────────────────────────────────────┐
│                                                          │
│  🔴 Chase missing evidence: sponsorship certificate      │
│     Policy: SW-COS-VALID                                 │
│     Guidance: "Check CoS ref against SMS system.         │
│     Verify sponsor licence is still active."             │
│     📋 View full policy →  💬 Generate chase letter →    │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Applicant Portal — Status View

The applicant sees the plain-English version with a helpful link:

```
┌─ Your application: VIS-2024-00847 ───────────────────────┐
│                                                          │
│  Status: Waiting for a document from you                 │
│                                                          │
│  ⚠️ We need your sponsorship certificate                 │
│     Your employer must give you a certificate of         │
│     sponsorship (CoS) before you can proceed.            │
│     This is a reference number, not a physical document. │
│                                                          │
│     📖 Read more on GOV.UK →                             │
│     https://www.gov.uk/skilled-worker-visa/your-job      │
│                                                          │
│  ✅ Passport — received                                  │
│  ✅ English language test — accepted                     │
│  ✅ TB certificate — accepted                            │
│  ✅ Bank statements — accepted                           │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Correspondence Generation

When a caseworker clicks "Generate chase letter" on action, the system pre-fills:

```ruby
# Auto-generated from Action + PolicyReference
correspondence = Correspondence.new(
  action: action,
  subject: "Your visa application #{kase.reference} — we need your sponsorship certificate",
  body: generate_from_template(action, policy_ref),
  policy_reference: action.policy_reference,
  policy_explanation: policy_ref.applicant_summary,
  guidance_url: policy_ref.applicant_url,
  channel: :portal # or :email, :letter
)
```

The letter/email/portal message includes:
1. What's needed (from `action.title`)
2. Why it's needed (from `policyRef.applicantSummary`)
3. Where to find out more (from `policyRef.applicantUrl`)

---

## Calculated Fields (Compute in Controller/Model, Not Stored)

```ruby
# app/models/case.rb — add to the Case model
class Case < ApplicationRecord
  # ... associations and enums above ...

  def calculate_risk_score
    score = 0

    days_until_sla = (sla_deadline.to_date - Date.current).to_i

    if days_until_sla <= 0    then score += 50  # Already overdue
    elsif days_until_sla <= 7 then score += 30  # Less than a week
    elsif days_until_sla <= 14 then score += 15 # Less than 2 weeks
    end

    missing = evidences.not_received.count
    score += missing * 10  # Each missing doc adds risk

    pending = actions.pending.count
    score += pending * 5   # Pending actions add risk

    score += 20 if urgent?
    score += 10 if high?

    [score, 100].min
  end

  def self.sla_compliance_rate
    decided = where.not(decided_at: nil)
    return 100.0 if decided.empty?

    on_time = decided.where("decided_at <= sla_deadline")
    (on_time.count.to_f / decided.count * 100).round(1)
  end
end
```
