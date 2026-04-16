class CaseTypeGeneratorStub
  ANALYSIS_RESPONSE = {
    conversation_id: "conv_stub_001",
    questions: [
      {
        id: "q1",
        text: "Who is the primary decision-maker for this process?",
        suggested_answers: [
          "A dedicated caseworker within the department",
          "A senior officer or team leader",
          "An automated system with officer oversight"
        ]
      },
      {
        id: "q2",
        text: "What happens when the applicant does not respond to a request for information?",
        suggested_answers: [
          "The case is closed after 14 days",
          "A reminder is sent, then closed after 28 days",
          "The case remains open indefinitely"
        ]
      },
      {
        id: "q3",
        text: "Is there an appeal or review process if the application is refused?",
        suggested_answers: [
          "Yes — formal appeal to an independent panel",
          "Yes — internal review by a senior officer",
          "No appeal route exists"
        ]
      }
    ]
  }.freeze

  GENERATION_RESPONSE = {
    name: "Black Bag Limit Exemption",
    slug: "black_bag_exemption",
    description: "Residents in Swansea can apply for an exemption to the 3 black bag limit if they have non-recyclable waste such as pet litter or nappies.",
    default_sla_days: 14,
    decision_tree_md: <<~MD,
      ## Decision Tree — Black Bag Limit Exemption

      ```
      BLACK BAG LIMIT EXEMPTION APPLICATION
      │
      ├─ Is the applicant a Swansea Council resident?
      │   ├─ NO → REJECT (not eligible — service area restriction)
      │   └─ YES ↓
      │
      ├─ What is the exemption reason?
      │   ├─ NAPPIES → Continue ↓
      │   ├─ PET LITTER → Continue ↓
      │   ├─ PET BEDDING → Continue ↓
      │   └─ OTHER / NOT SPECIFIED → REQUEST clarification from applicant
      │
      ├─ Is the applicant currently recycling all accepted kerbside materials?
      │   ├─ NO / UNKNOWN → REJECT (precondition not met)
      │   └─ YES ↓
      │
      ├─ Does the applicant produce more than 3 bags of non-recyclable waste?
      │   ├─ NO → REJECT (exemption not needed)
      │   └─ YES ↓
      │
      ├─ Are there any recyclable materials in the black bags?
      │   ├─ YES → REJECT (condition: no recyclable material in any bags)
      │   ├─ UNKNOWN → SCHEDULE monitoring visit
      │   └─ NO ↓
      │
      └─ GRANT EXEMPTION
          Duration: 1 year from date of approval
          Conditions: continued recycling compliance, no recyclable material in bags
          Review date: 12 months from grant
      ```
    MD
    state_transitions_md: <<~MD,
      ## State Transitions

      | Current State | Trigger | Next State | Action |
      |---|---|---|---|
      | SUBMITTED | Application received | ASSIGNED | Auto-assign to waste team officer |
      | ASSIGNED | Officer opens case | IN_REVIEW | Begin eligibility checks |
      | IN_REVIEW | Recycling compliance unclear | MONITORING | Schedule monitoring visit |
      | IN_REVIEW | All checks pass | READY_FOR_DECISION | — |
      | IN_REVIEW | Incomplete form | AWAITING_INFO | Request missing info from applicant |
      | AWAITING_INFO | Info received | IN_REVIEW | Resume review |
      | AWAITING_INFO | No response 14 days | CLOSED_NO_RESPONSE | Auto-close |
      | MONITORING | Visit confirms compliance | READY_FOR_DECISION | — |
      | MONITORING | Visit finds recyclables in bags | REJECTED | Issue rejection notice |
      | READY_FOR_DECISION | Officer approves | GRANTED | Issue exemption for 1 year |
      | READY_FOR_DECISION | Officer rejects | REJECTED | Issue rejection notice |
      | GRANTED | 11 months elapsed | REVIEW_DUE | Notify officer: review upcoming |
      | REVIEW_DUE | Officer reviews + renews | GRANTED | Reset 1 year timer |
      | REVIEW_DUE | Officer reviews + revokes | REVOKED | Issue revocation notice |
    MD
    evidence_requirements_md: <<~MD,
      ## Evidence Requirements

      | Evidence | Required? | Source | Verification |
      |---|---|---|---|
      | Name and address | Mandatory | Applicant (form) | Check against council tax records |
      | Exemption reason (nappies/pet litter/pet bedding) | Mandatory | Applicant (form) | Self-declared |
      | Confirmation of kerbside recycling | Mandatory | Council systems | Check collection records |
      | Additional information | Optional | Applicant (form) | Officer review |
    MD
    risk_scoring_md: <<~MD,
      ## Risk Scoring Rules

      | Factor | Points | Condition |
      |---|---|---|
      | Previous exemption expired without renewal | +2 | Check historical records |
      | Monitoring visit previously failed | +3 | Flag from previous case |
      | Multiple applications in 12 months | +1 | Count recent applications |
      | No recycling collection history | +2 | Missing from council systems |
      | High-volume waste area | +1 | Postcode-based flag |

      **Risk thresholds:**
      - 0–2: Low risk — standard processing
      - 3–4: Medium risk — senior officer review
      - 5+: High risk — mandatory monitoring visit before decision
    MD
    correspondence_templates_md: <<~MD
      ## Correspondence Templates

      ### Acknowledgement Letter

      > Dear {{ applicant_name }},
      >
      > Thank you for your application for a black bag limit exemption. Your reference number is {{ reference }}.
      >
      > We aim to process your application within {{ sla_days }} working days. If we need any further information, we will contact you.

      ### Approval Letter

      > Dear {{ applicant_name }},
      >
      > Your application for a black bag limit exemption has been approved.
      >
      > **Exemption details:**
      > - Reason: {{ exemption_reason }}
      > - Valid from: {{ start_date }}
      > - Valid until: {{ end_date }}
      > - Conditions: You must continue to recycle all accepted kerbside materials.

      ### Rejection Letter

      > Dear {{ applicant_name }},
      >
      > We have reviewed your application for a black bag limit exemption and are unable to grant an exemption at this time.
      >
      > **Reason:** {{ rejection_reason }}
      >
      > If you believe this decision is incorrect, you may request a review by contacting us within 28 days.
    MD
  }.freeze

  SUGGESTIONS_RESPONSE = {
    suggestions: [
      {
        title: "Add automatic reminder for non-response",
        description: "When an applicant doesn't respond to a request for information within 7 days, send an automatic reminder before the 14-day closure. This improves completion rates and reduces unnecessary case closures.",
        category: "Business process efficiency",
        priority: "high",
        impact_description: "Could reduce case closures due to non-response by 30-40%",
        standard_reference: "GDS Service Standard #3 — Provide a joined up experience"
      },
      {
        title: "Add equalities monitoring data collection",
        description: "Collect optional equalities monitoring data (anonymised) to ensure the exemption process doesn't disproportionately affect protected groups. This supports compliance with the Public Sector Equality Duty.",
        category: "Compliance & fairness",
        priority: "medium",
        impact_description: "Enables statutory equalities reporting and identifies potential bias",
        standard_reference: "Equality Act 2010, s.149 — Public Sector Equality Duty"
      },
      {
        title: "Enable online self-service renewal",
        description: "Allow existing exemption holders to renew online without officer intervention when their compliance record is clean. This reduces officer workload and improves the citizen experience.",
        category: "Customer experience",
        priority: "medium",
        impact_description: "Could automate ~60% of renewals, saving officer time",
        standard_reference: "GDS Service Standard #1 — Understand users and their needs"
      },
      {
        title: "Add SLA breach escalation path",
        description: "Automatically escalate cases that exceed the SLA deadline to a senior officer. Currently there's no handling for SLA breaches, which could leave applicants waiting indefinitely.",
        category: "Operational resilience",
        priority: "high",
        impact_description: "Prevents cases from being lost or delayed beyond SLA",
        standard_reference: "GDS Service Standard #14 — Operate a reliable service"
      }
    ]
  }.freeze

  APPLY_SUGGESTIONS_RESPONSE = {
    applied: true,
    summary: "Applied 2 accepted suggestions to the case type configuration. Updated state transitions to include automatic reminders and SLA breach escalation paths."
  }.freeze

  # Simulates the scrape + analyse step. Returns questions and a conversation_id.
  def scrape_and_analyse!(description:, urls: [])
    sleep 5 # Simulate LLM processing time
    ANALYSIS_RESPONSE.deep_dup
  end

  # Simulates the generate step after clarifying questions are answered.
  def generate_config!(conversation_id:, answers_text:)
    sleep 5 # Simulate LLM processing time
    GENERATION_RESPONSE.deep_dup
  end

  # Simulates the process improvement suggestions step.
  def suggest_improvements!(case_type_config:)
    sleep 5 # Simulate LLM processing time
    SUGGESTIONS_RESPONSE.deep_dup
  end

  # Simulates applying accepted suggestions to the config.
  def apply_suggestions!(case_type_config:, accepted_suggestions:, comments:)
    sleep 5 # Simulate LLM processing time
    APPLY_SUGGESTIONS_RESPONSE.deep_dup
  end
end
