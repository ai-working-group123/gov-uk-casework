# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

team = Team.find_or_create_by!(name: "Immigration Operations") do |record|
	record.leader_id = nil
end

builder_caseworker = Caseworker.find_or_create_by!(email: "builder.caseworker@gov.uk") do |record|
	record.name = "Case Type Builder Seed User"
	record.team = team
	record.role = :team_leader
	record.capacity = 20
end

skilled_worker_policy_references = [
	{
		code: "SW",
		parent_code: nil,
		title: "Skilled Worker Visa",
		policy_area: "Skilled Worker Visa",
		case_types: "tier2_work",
		summary: "Core requirements for Skilled Worker visa applications.",
		criteria: "Valid CoS, licensed sponsor, English, maintenance, conditional evidence checks, and refusal grounds.",
		govuk_url: "https://www.gov.uk/skilled-worker-visa",
		legislation_url: "https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-skilled-worker",
		applicant_summary: "You need an eligible job offer from an approved sponsor and must meet route requirements.",
		applicant_url: "https://www.gov.uk/skilled-worker-visa"
	},
	{
		code: "SW-PASSPORT",
		parent_code: "SW",
		title: "Valid passport",
		policy_area: "Skilled Worker Visa",
		case_types: "tier2_work",
		summary: "Applicant must provide a valid passport.",
		criteria: "Passport identity details and expiry date must be valid for application processing.",
		govuk_url: "https://www.gov.uk/skilled-worker-visa",
		applicant_summary: "You must provide a valid passport or travel document.",
		applicant_url: "https://www.gov.uk/skilled-worker-visa"
	},
	{
		code: "SW-COS",
		parent_code: "SW",
		title: "Certificate of Sponsorship",
		policy_area: "Skilled Worker Visa",
		case_types: "tier2_work",
		summary: "A valid Certificate of Sponsorship (CoS) is mandatory.",
		criteria: "CoS must be assigned to applicant, unspent, and issued by a currently licensed sponsor.",
		govuk_url: "https://www.gov.uk/skilled-worker-visa/your-job",
		applicant_summary: "Your sponsor must provide a valid certificate of sponsorship reference number.",
		applicant_url: "https://www.gov.uk/skilled-worker-visa/your-job"
	},
	{
		code: "SW-ENGLISH",
		parent_code: "SW",
		title: "English language evidence",
		policy_area: "Skilled Worker Visa",
		case_types: "tier2_work",
		summary: "English language requirement must be met.",
		criteria: "Evidence must show CEFR B1+ or a valid exemption route.",
		govuk_url: "https://www.gov.uk/skilled-worker-visa/knowledge-of-english",
		applicant_summary: "You must show the required level of English unless exempt.",
		applicant_url: "https://www.gov.uk/skilled-worker-visa/knowledge-of-english"
	},
	{
		code: "SW-TB",
		parent_code: "SW",
		title: "TB test certificate",
		policy_area: "Skilled Worker Visa",
		case_types: "tier2_work",
		summary: "TB certificate is required only for specific nationalities.",
		criteria: "If applicant is from a listed country, valid TB certificate from approved clinic is required.",
		govuk_url: "https://www.gov.uk/tb-test-visa/countries-where-you-need-a-tb-test",
		applicant_summary: "Some applicants must provide a valid TB test certificate.",
		applicant_url: "https://www.gov.uk/tb-test-visa/countries-where-you-need-a-tb-test"
	},
	{
		code: "SW-CRC",
		parent_code: "SW",
		title: "Criminal record certificate",
		policy_area: "Skilled Worker Visa",
		case_types: "tier2_work",
		summary: "Criminal record certificate is conditional for specified occupations.",
		criteria: "Required where job involves working with vulnerable groups under route rules.",
		govuk_url: "https://www.gov.uk/skilled-worker-visa",
		applicant_summary: "For some roles, you must provide a criminal record certificate.",
		applicant_url: "https://www.gov.uk/skilled-worker-visa"
	},
	{
		code: "SW-MAINTENANCE",
		parent_code: "SW",
		title: "Maintenance funds evidence",
		policy_area: "Skilled Worker Visa",
		case_types: "tier2_work",
		summary: "Financial requirement evidence is conditional.",
		criteria: "Show GBP 1,270 for 28 consecutive days unless sponsor certifies maintenance.",
		govuk_url: "https://www.gov.uk/skilled-worker-visa/money",
		applicant_summary: "You may need to show funds for maintenance unless your sponsor covers this.",
		applicant_url: "https://www.gov.uk/skilled-worker-visa/money"
	},
	{
		code: "SW-ACADEMIC",
		parent_code: "SW",
		title: "Academic qualifications",
		policy_area: "Skilled Worker Visa",
		case_types: "tier2_work",
		summary: "Academic evidence may be needed where role-specific qualifications apply.",
		criteria: "Provide qualification evidence where sponsor role or route rules require it.",
		govuk_url: "https://www.gov.uk/skilled-worker-visa",
		applicant_summary: "Some jobs require evidence of specific qualifications.",
		applicant_url: "https://www.gov.uk/skilled-worker-visa"
	},
	{
		code: "SW-BIOMETRICS",
		parent_code: "SW",
		title: "Biometric enrolment",
		policy_area: "Skilled Worker Visa",
		case_types: "tier2_work",
		summary: "Biometric enrolment is mandatory.",
		criteria: "Applicant must complete biometric enrolment (photo and fingerprints) via VAC/UKVCAS.",
		govuk_url: "https://www.gov.uk/skilled-worker-visa",
		applicant_summary: "You must provide your biometric information as part of your application.",
		applicant_url: "https://www.gov.uk/skilled-worker-visa"
	},
	{
		code: "SW-ATAS",
		parent_code: "SW",
		title: "ATAS certificate",
		policy_area: "Skilled Worker Visa",
		case_types: "tier2_work",
		summary: "ATAS evidence is conditional for specified research roles.",
		criteria: "ATAS certificate is required for certain roles where route guidance says so.",
		govuk_url: "https://www.gov.uk/academic-technology-approval-scheme",
		applicant_summary: "For some research-related roles, you need an ATAS certificate.",
		applicant_url: "https://www.gov.uk/academic-technology-approval-scheme"
	}
]

skilled_worker_policy_references.each do |attrs|
	policy_reference = PolicyReference.find_or_initialize_by(code: attrs[:code])
	policy_reference.update!(attrs)
end

decision_tree_md = <<~MD
	START
	|
	|- Is CoS valid and sponsor licensed?
	|  |- NO -> Request valid CoS or refuse
	|  |- YES
	|
	|- Skill and salary thresholds met?
	|  |- NO -> Refuse
	|  |- YES
	|
	|- English and maintenance requirements met?
	|  |- NO -> Request evidence or refuse
	|  |- YES
	|
	|- Conditional checks: TB, criminal record, ATAS (where required)
	|  |- Missing required evidence -> Request or refuse
	|
	|- Part 9 refusal grounds clear?
	|  |- NO -> Refuse or escalate
	|  |- YES -> Grant
MD

state_transitions_md = <<~MD
	SUBMITTED -> ASSIGNED -> IN_REVIEW -> AWAITING_EVIDENCE -> READY_FOR_DECISION -> DECIDED_APPROVED/DECIDED_REFUSED
MD

evidence_requirements_md = <<~MD
	| Evidence | Required? | Source | Verification Method |
	|---|---|---|---|
	| Valid passport | Mandatory | Applicant | Check expiry and identity details |
	| Certificate of Sponsorship (CoS) | Mandatory | Sponsor | SMS lookup and sponsor licence validation |
	| Proof of English language | Mandatory | Test centre or exemption route | Validate approved proof at CEFR B1+ |
	| TB test certificate | Conditional | Approved clinic | Required only for listed countries |
	| Criminal record certificate | Conditional | Police authority | Required for vulnerable-sector roles |
	| Bank statements (maintenance) | Conditional | Applicant or sponsor | GBP 1,270 for 28 consecutive days unless sponsor certifies maintenance |
	| Academic qualifications | Sometimes | University or ECCTIS | Required where role needs qualification evidence |
	| Biometric enrolment | Mandatory | VAC or UKVCAS | Confirm completed enrolment |
	| ATAS certificate | Conditional | FCDO | Required for specific research roles |
MD

correspondence_templates_md = <<~MD
	## Chase missing CoS
	Subject: Skilled Worker application update - Certificate of Sponsorship required

	We cannot progress your application without a valid Certificate of Sponsorship reference.
	Please upload this evidence by the stated deadline.

	## Chase conditional evidence
	Subject: Skilled Worker application update - additional evidence required

	We need additional route-specific evidence (for example TB, criminal record, or ATAS) to continue casework.
MD

risk_scoring_md = <<~MD
	Start at 0.
	+40 if SLA breached, +25 if SLA within 7 days, +10 if within 14 days.
	+20 if evidence completeness < 50%, +10 if < 80%.
	+10 for high priority, +15 for urgent priority.
	+10 if no activity > 14 days, +20 if > 28 days.
	Cap at 100.
MD

case_type_config = CaseTypeConfig.find_or_initialize_by(slug: "skilled-worker-visa")
case_type_config.update!(
	name: "Skilled Worker Visa",
	description: "Case type configuration for Skilled Worker applications, including checklist evidence and decisioning flow.",
	organisation: "UK Visas and Immigration",
	status: :published,
	default_sla_days: 56,
	decision_tree_md: decision_tree_md,
	state_transitions_md: state_transitions_md,
	evidence_requirements_md: evidence_requirements_md,
	correspondence_templates_md: correspondence_templates_md,
	risk_scoring_md: risk_scoring_md,
	source_metadata: {
		source_document: "docs/CHALLENGE_3_ANALYSIS.md",
		source_section: "Skilled Worker Visa - Evidence Requirements",
		policy_codes: skilled_worker_policy_references.map { |policy| policy[:code] }
	},
	created_by: builder_caseworker
)

generation_logs = [
	{
		step: 1,
		step_name: "analysis",
		input_text: "Extract Skilled Worker evidence requirements and conditional checks.",
		output_text: "Captured mandatory, conditional, and sometimes-required evidence list.",
		model_used: "manual-seed",
		tokens_used: 0,
		confidence_score: 0.91
	},
	{
		step: 2,
		step_name: "decision-tree",
		input_text: "Translate route rules into simplified decision tree markdown.",
		output_text: "Generated a grant/refuse oriented flow with escalation points.",
		model_used: "manual-seed",
		tokens_used: 0,
		confidence_score: 0.88
	},
	{
		step: 3,
		step_name: "templates",
		input_text: "Create correspondence templates for common missing-evidence paths.",
		output_text: "Produced chase templates for CoS and conditional evidence.",
		model_used: "manual-seed",
		tokens_used: 0,
		confidence_score: 0.86
	}
]

generation_logs.each do |attrs|
	log = CaseTypeGenerationLog.find_or_initialize_by(case_type_config: case_type_config, step: attrs[:step])
	log.update!(attrs)
end

suggestions = [
	{
		title: "Add sponsor licence recheck before decision",
		description: "Re-validate sponsor licence status at READY_FOR_DECISION to catch post-submission suspensions.",
		category: "decision_tree",
		priority: :high,
		impact_description: "Reduces grant risk when sponsor status changes mid-case.",
		standard_reference: "Appendix Skilled Worker",
		status: :accepted,
		resolved_by: builder_caseworker,
		resolved_at: Time.current
	},
	{
		title: "Add explicit maintenance exemption branch",
		description: "Branch evidence guidance based on whether sponsor certifies maintenance on CoS.",
		category: "evidence_requirements",
		priority: :medium,
		impact_description: "Avoids unnecessary maintenance document requests.",
		standard_reference: "Skilled Worker visa money guidance",
		status: :suggested
	}
]

suggestions.each do |attrs|
	suggestion = CaseTypeSuggestion.find_or_initialize_by(case_type_config: case_type_config, title: attrs[:title])
	suggestion.update!(attrs)
end

seed_caseworkers = [
	{ email: "sarah.chen@gov.uk", name: "Sarah Chen", role: :senior_caseworker, capacity: 14 },
	{ email: "fatima.ali@gov.uk", name: "Fatima Ali", role: :caseworker, capacity: 18 },
	{ email: "david.park@gov.uk", name: "David Park", role: :caseworker, capacity: 12 },
	{ email: "nia.williams@gov.uk", name: "Nia Williams", role: :caseworker, capacity: 12 }
]

seed_caseworkers.each do |attrs|
	caseworker = Caseworker.find_or_initialize_by(email: attrs[:email])
	caseworker.update!(
		name: attrs[:name],
		team: team,
		role: attrs[:role],
		capacity: attrs[:capacity]
	)
end

caseworker_by_email = Caseworker.where(email: seed_caseworkers.map { |attrs| attrs[:email] }).index_by(&:email)
policy_reference_by_code = PolicyReference.where(code: skilled_worker_policy_references.map { |attrs| attrs[:code] }).index_by(&:code)

seed_cases = [
	{
		reference: "HO-T2-PRI1",
		applicant_name: "Priya Sharma",
		applicant_email: "priya.sharma@example.com",
		nationality: "Indian",
		assigned_to_email: "fatima.ali@gov.uk",
		status: :awaiting_evidence,
		priority: :urgent,
		submitted_at: 9.weeks.ago,
		assigned_at: 8.weeks.ago,
		sla_deadline: 1.week.ago,
		case_type: :tier2_work,
		evidence_items: [
			{ evidence_type: :passport, status: :accepted, policy_code: "SW-PASSPORT", required_by: 6.weeks.ago, received_at: 8.weeks.ago, reviewed_at: 7.weeks.ago },
			{ evidence_type: :english_language, status: :accepted, policy_code: "SW-ENGLISH", required_by: 6.weeks.ago, received_at: 7.weeks.ago, reviewed_at: 6.weeks.ago },
			{ evidence_type: :sponsorship_certificate, status: :not_received, policy_code: "SW-COS", required_by: 5.weeks.ago, notes: "Employer has not provided valid CoS reference yet." },
			{ evidence_type: :bank_statements, status: :received, policy_code: "SW-MAINTENANCE", required_by: 6.weeks.ago, received_at: 5.weeks.ago },
			{ evidence_type: :tb_certificate, status: :accepted, policy_code: "SW-TB", required_by: 6.weeks.ago, received_at: 7.weeks.ago, reviewed_at: 6.weeks.ago },
			{ evidence_type: :biometrics, status: :accepted, policy_code: "SW-BIOMETRICS", required_by: 6.weeks.ago, received_at: 6.weeks.ago, reviewed_at: 6.weeks.ago }
		]
	},
	{
		reference: "HO-T2-CHEN",
		applicant_name: "Chen Wei",
		applicant_email: "chen.wei@example.com",
		nationality: "Chinese",
		assigned_to_email: "david.park@gov.uk",
		status: :assigned,
		priority: :medium,
		submitted_at: 1.day.ago,
		assigned_at: 12.hours.ago,
		sla_deadline: 7.weeks.from_now,
		case_type: :tier2_work,
		evidence_items: [
			{ evidence_type: :passport, status: :received, policy_code: "SW-PASSPORT", required_by: 2.weeks.from_now, received_at: 1.day.ago },
			{ evidence_type: :sponsorship_certificate, status: :not_received, policy_code: "SW-COS", required_by: 2.weeks.from_now },
			{ evidence_type: :english_language, status: :not_received, policy_code: "SW-ENGLISH", required_by: 2.weeks.from_now },
			{ evidence_type: :bank_statements, status: :not_received, policy_code: "SW-MAINTENANCE", required_by: 2.weeks.from_now },
			{ evidence_type: :biometrics, status: :not_received, policy_code: "SW-BIOMETRICS", required_by: 3.weeks.from_now }
		]
	},
	{
		reference: "HO-T2-AISH",
		applicant_name: "Aisha Hassan",
		applicant_email: "aisha.hassan@example.com",
		nationality: "Sudanese",
		assigned_to_email: "sarah.chen@gov.uk",
		status: :in_review,
		priority: :high,
		submitted_at: 3.weeks.ago,
		assigned_at: 19.days.ago,
		sla_deadline: 4.weeks.from_now,
		case_type: :tier2_work,
		evidence_items: [
			{ evidence_type: :passport, status: :accepted, policy_code: "SW-PASSPORT", required_by: 2.weeks.ago, received_at: 20.days.ago, reviewed_at: 18.days.ago },
			{ evidence_type: :sponsorship_certificate, status: :under_review, policy_code: "SW-COS", required_by: 2.weeks.ago, received_at: 18.days.ago },
			{ evidence_type: :english_language, status: :accepted, policy_code: "SW-ENGLISH", required_by: 2.weeks.ago, received_at: 16.days.ago, reviewed_at: 14.days.ago },
			{ evidence_type: :tb_certificate, status: :received, policy_code: "SW-TB", required_by: 2.weeks.ago, received_at: 14.days.ago },
			{ evidence_type: :bank_statements, status: :under_review, policy_code: "SW-MAINTENANCE", required_by: 2.weeks.ago, received_at: 12.days.ago },
			# { evidence_type: :atas_certificate, status: :not_received, policy_code: "SW-ATAS", required_by: 1.week.from_now, notes: "ATAS may be required depending on role details." }
		]
	},
	{
		reference: "HO-T2-MARC",
		applicant_name: "Marco Rossi",
		applicant_email: "marco.rossi@example.com",
		nationality: "Italian",
		assigned_to_email: "nia.williams@gov.uk",
		status: :ready_for_decision,
		priority: :medium,
		submitted_at: 4.weeks.ago,
		assigned_at: 25.days.ago,
		sla_deadline: 3.weeks.from_now,
		case_type: :tier2_work,
		evidence_items: [
			{ evidence_type: :passport, status: :accepted, policy_code: "SW-PASSPORT", required_by: 3.weeks.ago, received_at: 26.days.ago, reviewed_at: 24.days.ago },
			{ evidence_type: :sponsorship_certificate, status: :accepted, policy_code: "SW-COS", required_by: 3.weeks.ago, received_at: 24.days.ago, reviewed_at: 22.days.ago },
			{ evidence_type: :english_language, status: :accepted, policy_code: "SW-ENGLISH", required_by: 3.weeks.ago, received_at: 22.days.ago, reviewed_at: 20.days.ago },
			{ evidence_type: :bank_statements, status: :accepted, policy_code: "SW-MAINTENANCE", required_by: 3.weeks.ago, received_at: 21.days.ago, reviewed_at: 19.days.ago },
			{ evidence_type: :biometrics, status: :accepted, policy_code: "SW-BIOMETRICS", required_by: 3.weeks.ago, received_at: 20.days.ago, reviewed_at: 18.days.ago }
		]
	},
	{
		reference: "HO-T2-JAME",
		applicant_name: "James OBrien",
		applicant_email: "james.obrien@example.com",
		nationality: "Nigerian",
		assigned_to_email: "sarah.chen@gov.uk",
		status: :decided_approved,
		priority: :high,
		submitted_at: 7.weeks.ago,
		assigned_at: 46.days.ago,
		sla_deadline: 1.week.from_now,
		decided_at: 1.day.ago,
		case_type: :tier2_work,
		evidence_items: [
			{ evidence_type: :passport, status: :accepted, policy_code: "SW-PASSPORT", required_by: 5.weeks.ago, received_at: 47.days.ago, reviewed_at: 45.days.ago },
			{ evidence_type: :sponsorship_certificate, status: :accepted, policy_code: "SW-COS", required_by: 5.weeks.ago, received_at: 45.days.ago, reviewed_at: 43.days.ago },
			{ evidence_type: :english_language, status: :accepted, policy_code: "SW-ENGLISH", required_by: 5.weeks.ago, received_at: 44.days.ago, reviewed_at: 42.days.ago },
			{ evidence_type: :bank_statements, status: :accepted, policy_code: "SW-MAINTENANCE", required_by: 5.weeks.ago, received_at: 43.days.ago, reviewed_at: 41.days.ago },
			{ evidence_type: :tb_certificate, status: :accepted, policy_code: "SW-TB", required_by: 5.weeks.ago, received_at: 42.days.ago, reviewed_at: 40.days.ago },
			{ evidence_type: :biometrics, status: :accepted, policy_code: "SW-BIOMETRICS", required_by: 5.weeks.ago, received_at: 41.days.ago, reviewed_at: 39.days.ago }
		]
	},
	{
		reference: "HO-T2-OLGA",
		applicant_name: "Olga Petrov",
		applicant_email: "olga.petrov@example.com",
		nationality: "Russian",
		assigned_to_email: "fatima.ali@gov.uk",
		status: :decided_refused,
		priority: :high,
		submitted_at: 6.weeks.ago,
		assigned_at: 38.days.ago,
		sla_deadline: 2.weeks.ago,
		decided_at: 5.days.ago,
		case_type: :tier2_work,
		evidence_items: [
			{ evidence_type: :passport, status: :accepted, policy_code: "SW-PASSPORT", required_by: 4.weeks.ago, received_at: 39.days.ago, reviewed_at: 37.days.ago },
			{ evidence_type: :sponsorship_certificate, status: :rejected, policy_code: "SW-COS", required_by: 4.weeks.ago, received_at: 36.days.ago, reviewed_at: 33.days.ago, notes: "CoS reference invalid and sponsor licence no longer active." },
			{ evidence_type: :english_language, status: :accepted, policy_code: "SW-ENGLISH", required_by: 4.weeks.ago, received_at: 35.days.ago, reviewed_at: 34.days.ago },
			{ evidence_type: :biometrics, status: :accepted, policy_code: "SW-BIOMETRICS", required_by: 4.weeks.ago, received_at: 34.days.ago, reviewed_at: 32.days.ago }
		]
	},
	{
		reference: "HO-T2-LINA",
		applicant_name: "Lina Ahmed",
		applicant_email: "lina.ahmed@example.com",
		nationality: "Egyptian",
		assigned_to_email: "david.park@gov.uk",
		status: :submitted,
		priority: :low,
		submitted_at: 3.hours.ago,
		assigned_at: nil,
		sla_deadline: 8.weeks.from_now,
		case_type: :tier2_work,
		evidence_items: [
			{ evidence_type: :passport, status: :not_received, policy_code: "SW-PASSPORT", required_by: 10.days.from_now },
			{ evidence_type: :sponsorship_certificate, status: :not_received, policy_code: "SW-COS", required_by: 10.days.from_now },
			{ evidence_type: :english_language, status: :not_received, policy_code: "SW-ENGLISH", required_by: 10.days.from_now }
		]
	}
]

seed_case_records = {}

seed_cases.each do |case_attrs|
	assigned_caseworker = case_attrs[:assigned_to_email] ? caseworker_by_email[case_attrs[:assigned_to_email]] : nil

	kase = Case.find_or_initialize_by(reference: case_attrs[:reference])
	kase.update!(
		applicant_name: case_attrs[:applicant_name],
		applicant_email: case_attrs[:applicant_email],
		nationality: case_attrs[:nationality],
		assigned_to: assigned_caseworker,
		assigned_at: case_attrs[:assigned_at],
		case_type: case_attrs[:case_type],
		status: case_attrs[:status],
		priority: case_attrs[:priority],
		submitted_at: case_attrs[:submitted_at],
		sla_deadline: case_attrs[:sla_deadline],
		decided_at: case_attrs[:decided_at]
	)

	seed_case_records[case_attrs[:reference]] = kase
end

seed_cases.each do |case_attrs|
	kase = seed_case_records[case_attrs[:reference]]

	case_attrs[:evidence_items].each do |evidence_attrs|
		evidence = Evidence.find_or_initialize_by(case: kase, evidence_type: evidence_attrs[:evidence_type])
		evidence.update!(
			status: evidence_attrs[:status],
			policy_reference: policy_reference_by_code[evidence_attrs[:policy_code]],
			notes: evidence_attrs[:notes],
			required_by: evidence_attrs[:required_by],
			received_at: evidence_attrs[:received_at],
			reviewed_at: evidence_attrs[:reviewed_at]
		)
	end
end

# ── Evidence Requests ──────────────────────────────────────────────────────────
# Seed EvidenceRequest + EvidenceRequestItem rows for representative cases.
# Covers: sent (awaiting response), partially fulfilled, fulfilled, expired.

evidence_request_scenarios = [
  {
    # PRI1 — awaiting_evidence: active request sent, CoS still missing
    case_ref: "HO-T2-PRI1",
    requested_by_email: "nia.williams@gov.uk",
    status: :sent,
    sent_at: 6.weeks.ago,
    deadline: 2.weeks.ago,
    notify_via: :email,
    cover_message: "Dear applicant, to progress your Skilled Worker visa application we require the following documents. Please upload them using the reference number provided.",
    items: [
      { evidence_type: :sponsorship_certificate, status: :pending,  submission_method: :digital, reason: "A valid Certificate of Sponsorship is required under Appendix Skilled Worker." },
      { evidence_type: :bank_statements,          status: :received, submission_method: :digital, reason: "Bank statements showing maintenance funds per SW-MAINTENANCE policy.", received_at: 5.weeks.ago }
    ]
  },
  {
    # CHEN — assigned: draft request prepared but not yet sent
    case_ref: "HO-T2-CHEN",
    requested_by_email: "nia.williams@gov.uk",
    status: :draft,
    sent_at: nil,
    deadline: 4.weeks.from_now,
    notify_via: :email,
    cover_message: "Draft — pending caseworker review before sending.",
    items: [
      { evidence_type: :passport,                 status: :pending, submission_method: :either,  reason: "Valid passport required to confirm identity and nationality." },
      { evidence_type: :sponsorship_certificate,  status: :pending, submission_method: :digital, reason: "CoS reference must be assigned and unspent per SW-COS." },
      { evidence_type: :english_language,         status: :pending, submission_method: :digital, reason: "Proof of English language proficiency required under SW-ENGLISH." },
      { evidence_type: :bank_statements,          status: :pending, submission_method: :digital, reason: "Maintenance funds evidence required per SW-MAINTENANCE." }
    ]
  },
  {
    # AISH — in_review: request sent, most items received, one pending
    case_ref: "HO-T2-AISH",
    requested_by_email: "fatima.ali@gov.uk",
    status: :partially_fulfilled,
    sent_at: 5.weeks.ago,
    deadline: 1.week.from_now,
    notify_via: :email,
    cover_message: "We require the following supporting documents to complete our review of your application.",
    items: [
      { evidence_type: :passport,                 status: :accepted, submission_method: :digital, reason: "Identity verification.", received_at: 4.weeks.ago },
      { evidence_type: :sponsorship_certificate,  status: :accepted, submission_method: :digital, reason: "CoS verification.", received_at: 4.weeks.ago },
      { evidence_type: :english_language,         status: :accepted, submission_method: :digital, reason: "English language requirement.", received_at: 3.weeks.ago },
      { evidence_type: :biometrics,               status: :pending,  submission_method: :physical, reason: "Biometric enrolment confirmation still outstanding." }
    ]
  },
  {
    # MARC — ready_for_decision: all evidence fulfilled
    case_ref: "HO-T2-MARC",
    requested_by_email: "david.park@gov.uk",
    status: :fulfilled,
    sent_at: 7.weeks.ago,
    deadline: 3.weeks.ago,
    notify_via: :email,
    cover_message: "Please provide the documents listed below to allow us to progress your application to decision.",
    items: [
      { evidence_type: :passport,                 status: :accepted, submission_method: :digital, reason: "Valid passport for identity.", received_at: 6.weeks.ago },
      { evidence_type: :sponsorship_certificate,  status: :accepted, submission_method: :digital, reason: "CoS verification.", received_at: 6.weeks.ago },
      { evidence_type: :english_language,         status: :accepted, submission_method: :digital, reason: "English language test results.", received_at: 5.weeks.ago },
      { evidence_type: :bank_statements,          status: :accepted, submission_method: :digital, reason: "Maintenance funds evidence.", received_at: 5.weeks.ago },
      { evidence_type: :biometrics,               status: :accepted, submission_method: :physical, reason: "Biometric enrolment.", received_at: 4.weeks.ago }
    ]
  },
  {
    # JAME — decided_approved: historical fulfilled request
    case_ref: "HO-T2-JAME",
    requested_by_email: "nia.williams@gov.uk",
    status: :fulfilled,
    sent_at: 10.weeks.ago,
    deadline: 6.weeks.ago,
    notify_via: :email,
    cover_message: "To process your visa application we require the following supporting evidence.",
    items: [
      { evidence_type: :passport,                 status: :accepted, submission_method: :digital, reason: "Passport identity check.", received_at: 9.weeks.ago },
      { evidence_type: :sponsorship_certificate,  status: :accepted, submission_method: :digital, reason: "CoS validity check.", received_at: 9.weeks.ago },
      { evidence_type: :english_language,         status: :accepted, submission_method: :digital, reason: "English proficiency requirement.", received_at: 8.weeks.ago },
      { evidence_type: :bank_statements,          status: :accepted, submission_method: :digital, reason: "Financial maintenance funds.", received_at: 8.weeks.ago },
      { evidence_type: :biometrics,               status: :accepted, submission_method: :physical, reason: "Biometric enrolment confirmation.", received_at: 7.weeks.ago }
    ]
  },
  {
    # OLGA — decided_refused: request expired with one rejected item
    case_ref: "HO-T2-OLGA",
    requested_by_email: "fatima.ali@gov.uk",
    status: :expired,
    sent_at: 8.weeks.ago,
    deadline: 4.weeks.ago,
    notify_via: :email,
    cover_message: "Please provide the listed documents within the deadline. Failure to do so may result in refusal.",
    items: [
      { evidence_type: :passport,                 status: :accepted, submission_method: :digital, reason: "Passport identity verification.", received_at: 7.weeks.ago },
      { evidence_type: :sponsorship_certificate,  status: :rejected, submission_method: :digital, reason: "CoS reference must be valid and assigned to applicant.", received_at: 6.weeks.ago },
      { evidence_type: :english_language,         status: :accepted, submission_method: :digital, reason: "English language evidence.", received_at: 6.weeks.ago },
      { evidence_type: :biometrics,               status: :accepted, submission_method: :physical, reason: "Biometric enrolment.", received_at: 6.weeks.ago }
    ]
  },
  {
    # LINA — submitted: no request sent yet (nothing to seed)
    # skip — it's realistic for a brand new case to have no evidence request
  }
]

evidence_request_scenarios.compact.each do |scenario|
  next if scenario.empty?

  kase = seed_case_records[scenario[:case_ref]]
  next unless kase

  caseworker = caseworker_by_email[scenario[:requested_by_email]]
  next unless caseworker

  er = EvidenceRequest.find_or_initialize_by(case: kase)
  er.update!(
    requested_by:  caseworker,
    status:        scenario[:status],
    sent_at:       scenario[:sent_at],
    deadline:      scenario[:deadline],
    notify_via:    scenario[:notify_via],
    cover_message: scenario[:cover_message]
  )

  scenario[:items].each do |item_attrs|
    evidence = Evidence.find_by(case: kase, evidence_type: item_attrs[:evidence_type])
    next unless evidence

    eri = EvidenceRequestItem.find_or_initialize_by(evidence_request: er, evidence: evidence)
    eri.update!(
      status:            item_attrs[:status],
      submission_method: item_attrs[:submission_method],
      reason:            item_attrs[:reason],
      received_at:       item_attrs[:received_at]
    )
  end

  puts "  EvidenceRequest #{scenario[:status]} for #{scenario[:case_ref]} — #{scenario[:items].count} items"
end

puts "Seed complete."

# ── Additional Policy References ───────────────────────────────────────────────
additional_policy_refs = [
  # Skilled Worker — granular criteria missing from initial set
  { code: "SW-SPONSOR-LICENCE", parent_code: "SW", title: "Sponsor must hold a valid licence",
    policy_area: "Skilled Worker Visa", case_types: "tier2_work",
    summary: "The employing organisation must appear on the Register of Licensed Sponsors.",
    criteria: "Check sponsor register. Licence must be active (not suspended/revoked). Tier 2 Worker route must be listed.",
    govuk_url: "https://www.gov.uk/skilled-worker-visa/your-job",
    applicant_summary: "Your employer must be an approved UK Visas and Immigration sponsor.",
    applicant_url: "https://www.gov.uk/skilled-worker-visa/your-job" },

  { code: "SW-SALARY", parent_code: "SW", title: "Salary threshold",
    policy_area: "Skilled Worker Visa", case_types: "tier2_work",
    summary: "General threshold £38,700/yr or the occupation going rate, whichever is higher.",
    criteria: "Check CoS salary. General: ≥£38,700. New entrant: 70% of going rate (min £30,960). Shortage occupation: 80% of going rate. Verify against SOC 2020 occupation code.",
    govuk_url: "https://www.gov.uk/skilled-worker-visa/your-job",
    applicant_summary: "Your job must pay at least the minimum salary for your occupation.",
    applicant_url: "https://www.gov.uk/skilled-worker-visa/your-job" },

  # Family Visa
  { code: "FV", parent_code: nil, title: "Family Visa",
    policy_area: "Family Visa", case_types: "family_visa",
    summary: "Join or remain with a family member who is British, settled or in the UK on a qualifying visa.",
    criteria: "Relationship requirement, financial requirement (sponsor income ≥ £29,000), English language, suitability. Route depends on relationship type.",
    govuk_url: "https://www.gov.uk/uk-family-visa",
    applicant_summary: "You may be able to come to the UK on a family visa if you have a partner, parent or child already here.",
    applicant_url: "https://www.gov.uk/uk-family-visa" },

  { code: "FV-RELATIONSHIP", parent_code: "FV", title: "Genuine relationship requirement",
    policy_area: "Family Visa", case_types: "family_visa",
    summary: "Must provide evidence of a genuine, subsisting relationship with the UK-based sponsor.",
    criteria: "Evidence of cohabitation, joint finances, joint tenancy, shared communications. Relationship must predate application by ≥2 years for partner route.",
    govuk_url: "https://www.gov.uk/uk-family-visa/partner-spouse",
    applicant_summary: "You need to show you have a genuine relationship with your UK family member.",
    applicant_url: "https://www.gov.uk/uk-family-visa/partner-spouse" },

  { code: "FV-FINANCE", parent_code: "FV", title: "Financial requirement (MFR)",
    policy_area: "Family Visa", case_types: "family_visa",
    summary: "Sponsoring partner must earn ≥ £29,000/yr gross (from 11 April 2024).",
    criteria: "Minimum income: £29,000 gross. Evidence: 6 months payslips + bank statements, or self-employment accounts. Savings can top up shortfall if ≥ £88,500 held for 6 months.",
    govuk_url: "https://www.gov.uk/uk-family-visa/financial-requirement",
    applicant_summary: "Your UK family member must earn enough money to support you both.",
    applicant_url: "https://www.gov.uk/uk-family-visa/financial-requirement" },

  { code: "FV-ENGLISH", parent_code: "FV", title: "English language (CEFR A1 initially, A2 at extension)",
    policy_area: "Family Visa", case_types: "family_visa",
    summary: "Must meet English language requirement at CEFR A1 for entry, A2 at first extension.",
    criteria: "Accepted: approved SELT at required level, degree taught in English (with ECCTIS), nationality of majority-English-speaking country, age ≥65.",
    govuk_url: "https://www.gov.uk/uk-family-visa/knowledge-of-english",
    applicant_summary: "You'll need to prove you can speak and understand basic English.",
    applicant_url: "https://www.gov.uk/uk-family-visa/knowledge-of-english" },

  # Student Visa
  { code: "T4", parent_code: nil, title: "Student Visa (Tier 4)",
    policy_area: "Student Visa", case_types: "tier4_student",
    summary: "Study at a licenced student sponsor (university, college or school) in the UK.",
    criteria: "Unconditional offer (CAS), CEFR B2 English, maintenance funds, ATAS if applicable, academic progress requirements.",
    govuk_url: "https://www.gov.uk/student-visa",
    applicant_summary: "The Student visa lets you study at a UK university or college.",
    applicant_url: "https://www.gov.uk/student-visa" },

  { code: "T4-CAS", parent_code: "T4", title: "Confirmation of Acceptance for Studies (CAS)",
    policy_area: "Student Visa", case_types: "tier4_student",
    summary: "Must have a valid CAS from a licenced Tier 4 sponsor.",
    criteria: "CAS must be unused, not expired (6 months from assignment), and match the application details. Course level must be NQF/QCF 3 or above.",
    govuk_url: "https://www.gov.uk/student-visa/documents-you-must-provide",
    applicant_summary: "Your university or college will give you a CAS number when they accept you onto a course.",
    applicant_url: "https://www.gov.uk/student-visa/documents-you-must-provide" },

  { code: "T4-MAINTENANCE", parent_code: "T4", title: "Maintenance funds for students",
    policy_area: "Student Visa", case_types: "tier4_student",
    summary: "London: £1,334/month × 9 (up to £12,006). Outside London: £1,023/month × 9 (up to £9,207).",
    criteria: "Funds must be held for 28 consecutive days ending within 31 days of application. Bank statements required unless sponsor is UKVI-approved and certifies maintenance.",
    govuk_url: "https://www.gov.uk/student-visa/money",
    applicant_summary: "You need to show you have enough money to support yourself during your studies.",
    applicant_url: "https://www.gov.uk/student-visa/money" },

  # Settlement
  { code: "SET", parent_code: nil, title: "Indefinite Leave to Remain (ILR)",
    policy_area: "Settlement", case_types: "settlement",
    summary: "Apply for indefinite leave to remain after qualifying continuous residence.",
    criteria: "5 years continuous lawful residence (or 3 for some routes), Life in the UK test, English B1+, no absences > 180 days/year, no serious criminal record.",
    govuk_url: "https://www.gov.uk/indefinite-leave-to-remain",
    applicant_summary: "Indefinite leave to remain (ILR) or settlement lets you live and work in the UK for as long as you like.",
    applicant_url: "https://www.gov.uk/indefinite-leave-to-remain" },

  { code: "SET-LITUK", parent_code: "SET", title: "Life in the UK test",
    policy_area: "Settlement", case_types: "settlement",
    summary: "Pass the Life in the UK test (24 questions, 75% pass mark).",
    criteria: "Must provide test pass letter. Test must have been taken in the last 3 years. Exempt if aged ≥65 or have physical/mental condition.",
    govuk_url: "https://www.gov.uk/life-in-the-uk-test",
    applicant_summary: "You need to pass the Life in the UK test before you can apply for indefinite leave to remain.",
    applicant_url: "https://www.gov.uk/life-in-the-uk-test" },

  { code: "SET-ABSENCES", parent_code: "SET", title: "Continuous residence — absences",
    policy_area: "Settlement", case_types: "settlement",
    summary: "No more than 180 days outside the UK in any 12-month period during qualifying residence.",
    criteria: "Check passport stamps and travel history. Total absences per year must not exceed 180 days. Exceptional circumstances (serious illness, COVID) may be considered.",
    govuk_url: "https://www.gov.uk/indefinite-leave-to-remain/eligibility",
    applicant_summary: "You must not have spent too much time outside the UK during the qualifying period.",
    applicant_url: "https://www.gov.uk/indefinite-leave-to-remain/eligibility" }
]

additional_policy_refs.each do |attrs|
  PolicyReference.find_or_create_by!(code: attrs[:code]) do |pr|
    pr.assign_attributes(attrs)
  end
end
puts "PolicyReferences: #{PolicyReference.count}"

# ── Helpers ────────────────────────────────────────────────────────────────────
cw_by_email = Caseworker.all.index_by(&:email)
case_by_ref = Case.all.index_by(&:reference)
pr_by_code  = PolicyReference.all.index_by(&:code)

# ── Actions ────────────────────────────────────────────────────────────────────
action_seeds = [
  # PRI1 — awaiting_evidence, overdue: chase the CoS, escalate
  { ref: "HO-T2-PRI1", title: "Chase missing Certificate of Sponsorship",
    action_type: :chase_evidence, status: :in_progress,
    due_date: 3.days.ago, policy_code: "SW-COS",
    description: "Priya's CoS has not been received. Employer must provide valid CoS reference immediately.",
    caseworker_guidance: "Check CoS reference in SMS system. Verify sponsor licence is active on the register. Send chase via portal and email. If no response in 5 working days, escalate.",
    blocked_by: nil },

  { ref: "HO-T2-PRI1", title: "Escalate to senior caseworker — SLA breach",
    action_type: :escalate, status: :pending,
    due_date: 1.day.from_now, policy_code: nil,
    description: "Case is 13 days overdue. Escalation required if CoS not received by end of week.",
    caseworker_guidance: "Prepare escalation note. Summarise timeline and evidence status. Submit to team leader.",
    blocked_by: "Chase evidence action must be completed first" },

  # CHEN — assigned, not yet started
  { ref: "HO-T2-CHEN", title: "Initial document review",
    action_type: :review_documents, status: :pending,
    due_date: 5.days.from_now, policy_code: "SW",
    description: "Case newly assigned. Review all submitted documents against Skilled Worker requirements.",
    caseworker_guidance: "Check passport validity, CoS details, English evidence. Create evidence request for anything missing.",
    blocked_by: nil },

  # AISH — in_review: reviewing docs, biometrics outstanding
  { ref: "HO-T2-AISH", title: "Review submitted documents",
    action_type: :review_documents, status: :in_progress,
    due_date: 2.days.from_now, policy_code: "SW",
    description: "Passport, CoS and English language evidence received and under review.",
    caseworker_guidance: "Verify CoS is unspent and sponsor licence active. Cross-reference salary on CoS with SW-SALARY thresholds.",
    blocked_by: nil },

  { ref: "HO-T2-AISH", title: "Chase biometric enrolment confirmation",
    action_type: :chase_evidence, status: :pending,
    due_date: 4.days.from_now, policy_code: "SW-BIOMETRICS",
    description: "Biometric enrolment confirmation still pending. Must be received before decision.",
    caseworker_guidance: "Check UKVCAS system for enrolment appointment status. Send reminder if appointment booked but confirmation not uploaded.",
    blocked_by: nil },

  # MARC — ready_for_decision
  { ref: "HO-T2-MARC", title: "Make decision — approve or refuse",
    action_type: :make_decision, status: :pending,
    due_date: 2.days.from_now, policy_code: "SW",
    description: "All evidence received and accepted. Case ready for final decision.",
    caseworker_guidance: "Review full evidence pack. Check salary meets SW-SALARY threshold, sponsor on register, CoS valid. If all checks pass, approve. Record decision rationale in case note.",
    blocked_by: nil },

  # JAME — decided_approved: historical completed actions
  { ref: "HO-T2-JAME", title: "Review and approve application",
    action_type: :make_decision, status: :completed,
    due_date: 5.weeks.ago, completed_at: 5.weeks.ago, policy_code: "SW",
    description: "All documents verified and checks passed. Application approved.",
    caseworker_guidance: nil, blocked_by: nil },

  { ref: "HO-T2-JAME", title: "Send approval notification to applicant",
    action_type: :send_correspondence, status: :completed,
    due_date: 5.weeks.ago, completed_at: 35.days.ago, policy_code: nil,
    description: "Notify applicant of successful outcome via portal and email.",
    caseworker_guidance: nil, blocked_by: nil },

  # OLGA — decided_refused: historical actions
  { ref: "HO-T2-OLGA", title: "Review and refuse application",
    action_type: :make_decision, status: :completed,
    due_date: 5.days.ago, completed_at: 5.days.ago, policy_code: "SW-COS",
    description: "CoS rejected — sponsor licence revoked. Grounds for refusal under SW-COS-VALID.",
    caseworker_guidance: nil, blocked_by: nil },

  { ref: "HO-T2-OLGA", title: "Send refusal letter",
    action_type: :send_correspondence, status: :completed,
    due_date: 5.days.ago, completed_at: 4.days.ago, policy_code: "SW-COS",
    description: "Issue formal refusal notice citing invalid CoS and revoked sponsor licence.",
    caseworker_guidance: nil, blocked_by: nil },

  # LINA — submitted, nothing started yet
  { ref: "HO-T2-LINA", title: "Assign and begin initial review",
    action_type: :review_documents, status: :pending,
    due_date: 3.days.from_now, policy_code: "SW",
    description: "New application. Assign to caseworker and begin document checklist.",
    caseworker_guidance: "Check all mandatory evidence items present. Create evidence request for missing items.",
    blocked_by: nil }
]

saved_actions = {}

action_seeds.each do |attrs|
  kase = case_by_ref[attrs[:ref]]
  next unless kase

  pr = attrs[:policy_code] ? pr_by_code[attrs[:policy_code]] : nil

  action = Action.find_or_initialize_by(case: kase, title: attrs[:title])
  action.update!(
    action_type:        attrs[:action_type],
    status:             attrs[:status],
    due_date:           attrs[:due_date],
    completed_at:       attrs[:completed_at],
    policy_reference:   pr,
    description:        attrs[:description],
    caseworker_guidance: attrs[:caseworker_guidance],
    blocked_by:         attrs[:blocked_by]
  )
  saved_actions["#{attrs[:ref]}:#{attrs[:title]}"] = action
end
puts "Actions: #{Action.count}"

# ── Case Notes ─────────────────────────────────────────────────────────────────
case_note_seeds = [
  # PRI1 — overdue, awaiting evidence
  { ref: "HO-T2-PRI1", cw: "fatima.ali@gov.uk", note_type: :system,   visible: false,
    content: "Case submitted. Assigned to Fatima Ali. SLA deadline: #{7.weeks.ago + 8.weeks}.",
    created_at: 7.weeks.ago },
  { ref: "HO-T2-PRI1", cw: "fatima.ali@gov.uk", note_type: :system,   visible: false,
    content: "Status changed from submitted → awaiting_evidence.",
    created_at: 6.weeks.ago },
  { ref: "HO-T2-PRI1", cw: "fatima.ali@gov.uk", note_type: :evidence, visible: false,
    content: "Bank statements received and under review. Certificate of Sponsorship still outstanding.",
    created_at: 5.weeks.ago },
  { ref: "HO-T2-PRI1", cw: "fatima.ali@gov.uk", note_type: :manual,   visible: false,
    content: "Contacted employer by phone — stated CoS has been raised and reference will be provided this week.",
    created_at: 3.weeks.ago },
  { ref: "HO-T2-PRI1", cw: "fatima.ali@gov.uk", note_type: :manual,   visible: false,
    content: "No CoS received. Case now 13 days past SLA. Escalation being prepared.",
    created_at: 2.days.ago },

  # CHEN — just assigned
  { ref: "HO-T2-CHEN", cw: "david.park@gov.uk", note_type: :system,  visible: false,
    content: "Case submitted. Assigned to David Park.",
    created_at: 4.days.ago },
  { ref: "HO-T2-CHEN", cw: "david.park@gov.uk", note_type: :manual,  visible: false,
    content: "Initial document check scheduled. All mandatory evidence items appear to be included in submission.",
    created_at: 2.days.ago },

  # AISH — in review
  { ref: "HO-T2-AISH", cw: "sarah.chen@gov.uk", note_type: :system,   visible: false,
    content: "Case submitted. Assigned to Sarah Chen.",
    created_at: 6.weeks.ago },
  { ref: "HO-T2-AISH", cw: "sarah.chen@gov.uk", note_type: :system,   visible: false,
    content: "Status changed to in_review. Document review commenced.",
    created_at: 4.weeks.ago },
  { ref: "HO-T2-AISH", cw: "sarah.chen@gov.uk", note_type: :evidence, visible: false,
    content: "Passport, CoS, and English language certificate all received and accepted. Biometric enrolment confirmation still awaited.",
    created_at: 3.weeks.ago },
  { ref: "HO-T2-AISH", cw: "sarah.chen@gov.uk", note_type: :manual,   visible: false,
    content: "CoS verified against SMS — valid and unspent. Sponsor licence active. Salary of £42,500 meets SW-SALARY threshold. Awaiting biometrics to proceed.",
    created_at: 2.weeks.ago },

  # MARC — ready for decision
  { ref: "HO-T2-MARC", cw: "nia.williams@gov.uk", note_type: :system,   visible: false,
    content: "Case submitted. Assigned to Nia Williams.",
    created_at: 8.weeks.ago },
  { ref: "HO-T2-MARC", cw: "nia.williams@gov.uk", note_type: :system,   visible: false,
    content: "All evidence received. Status changed to ready_for_decision.",
    created_at: 3.weeks.ago },
  { ref: "HO-T2-MARC", cw: "nia.williams@gov.uk", note_type: :manual,   visible: false,
    content: "Full review complete. CoS valid, salary £56,000 above threshold, English B2 confirmed, TB cert not required (Italian national). Ready to approve.",
    created_at: 2.weeks.ago },

  # JAME — decided approved
  { ref: "HO-T2-JAME", cw: "sarah.chen@gov.uk", note_type: :system,   visible: false,
    content: "Case submitted. Assigned to Sarah Chen.",
    created_at: 12.weeks.ago },
  { ref: "HO-T2-JAME", cw: "sarah.chen@gov.uk", note_type: :evidence, visible: false,
    content: "All 5 evidence items received and accepted.",
    created_at: 7.weeks.ago },
  { ref: "HO-T2-JAME", cw: "sarah.chen@gov.uk", note_type: :decision, visible: true,
    content: "Application approved. All requirements met under Appendix Skilled Worker. CoS valid, salary £48,000 above threshold, sponsor licence active.",
    created_at: 5.weeks.ago },
  { ref: "HO-T2-JAME", cw: nil, note_type: :system, visible: true,
    content: "Decision notification sent to applicant via portal and email.",
    created_at: 35.days.ago },

  # OLGA — decided refused
  { ref: "HO-T2-OLGA", cw: "fatima.ali@gov.uk", note_type: :system,   visible: false,
    content: "Case submitted. Assigned to Fatima Ali.",
    created_at: 9.weeks.ago },
  { ref: "HO-T2-OLGA", cw: "fatima.ali@gov.uk", note_type: :evidence, visible: false,
    content: "CoS reference provided but validation failed — CoS assigned to different applicant name.",
    created_at: 6.weeks.ago },
  { ref: "HO-T2-OLGA", cw: "fatima.ali@gov.uk", note_type: :manual,   visible: false,
    content: "Sponsor licence check: TechStart Ltd licence revoked 3 weeks ago. CoS therefore invalid.",
    created_at: 5.weeks.ago },
  { ref: "HO-T2-OLGA", cw: "fatima.ali@gov.uk", note_type: :decision, visible: true,
    content: "Application refused under SW-COS. Sponsor TechStart Ltd licence revoked prior to application decision date. CoS cannot be considered valid.",
    created_at: 5.days.ago },

  # LINA — just submitted
  { ref: "HO-T2-LINA", cw: "david.park@gov.uk", note_type: :system, visible: false,
    content: "Case submitted. Assigned to David Park. SLA deadline 8 weeks from submission.",
    created_at: 3.hours.ago }
]

case_note_seeds.each do |attrs|
  kase = case_by_ref[attrs[:ref]]
  cw   = attrs[:cw] ? cw_by_email[attrs[:cw]] : nil
  next unless kase

  note = CaseNote.find_or_initialize_by(case: kase, content: attrs[:content])
  note.assign_attributes(caseworker: cw, note_type: attrs[:note_type], visible_to_applicant: attrs[:visible])
  note.save!
  note.update_columns(created_at: attrs[:created_at], updated_at: attrs[:created_at]) if attrs[:created_at]
end
puts "CaseNotes: #{CaseNote.count}"

# ── Correspondences ────────────────────────────────────────────────────────────
correspondence_seeds = [
  # PRI1 — chase letter for CoS
  { action_key: "HO-T2-PRI1:Chase missing Certificate of Sponsorship",
    channel: :portal, direction: :outbound,
    subject: "Your visa application HO-T2-PRI1 — action required: Certificate of Sponsorship",
    body: "Dear Priya Sharma,\n\nWe are writing regarding your Skilled Worker visa application (reference: HO-T2-PRI1).\n\nWe are still waiting for your Certificate of Sponsorship (CoS) reference number. Your employer must provide this before we can progress your application.\n\nYour CoS reference is a number given to you by your employer. It is not a physical document.\n\nPlease ask your employer to provide this as a matter of urgency. Your application is currently overdue.\n\nFor more information, visit: https://www.gov.uk/skilled-worker-visa/your-job\n\nUK Visas and Immigration",
    policy_code: "SW-COS",
    policy_explanation: "A valid Certificate of Sponsorship is required under Appendix Skilled Worker. Your sponsor must assign it to you before you can proceed.",
    guidance_url: "https://www.gov.uk/skilled-worker-visa/your-job",
    sent_at: 6.weeks.ago },

  { action_key: "HO-T2-PRI1:Chase missing Certificate of Sponsorship",
    channel: :email, direction: :outbound,
    subject: "REMINDER: CoS required — HO-T2-PRI1 overdue",
    body: "Dear Priya Sharma,\n\nThis is a reminder that your Certificate of Sponsorship is still outstanding.\n\nYour application (HO-T2-PRI1) cannot proceed without it. Please contact your employer urgently.\n\nUK Visas and Immigration",
    policy_code: "SW-COS",
    policy_explanation: "Reminder: CoS required under Appendix Skilled Worker.",
    guidance_url: "https://www.gov.uk/skilled-worker-visa/your-job",
    sent_at: 3.weeks.ago },

  # AISH — acknowledgement correspondence
  { action_key: "HO-T2-AISH:Review submitted documents",
    channel: :portal, direction: :outbound,
    subject: "Your visa application HO-T2-AISH — documents received",
    body: "Dear Aisha Hassan,\n\nThank you for submitting your supporting documents.\n\nWe have received your passport, certificate of sponsorship, and English language certificate. These are currently under review.\n\nWe are still waiting for your biometric enrolment confirmation. Please ensure you complete your biometric appointment and upload the confirmation letter.\n\nUK Visas and Immigration",
    policy_code: "SW-BIOMETRICS",
    policy_explanation: "Biometric enrolment is a mandatory requirement for all visa applications.",
    guidance_url: "https://www.gov.uk/biometric-residence-permits",
    sent_at: 3.weeks.ago },

  # JAME — approval letter
  { action_key: "HO-T2-JAME:Send approval notification to applicant",
    channel: :email, direction: :outbound,
    subject: "Your visa application HO-T2-JAME — successful",
    body: "Dear James O'Brien,\n\nWe are pleased to inform you that your Skilled Worker visa application (reference: HO-T2-JAME) has been approved.\n\nYour visa vignette will be issued separately. Please check your email and the applicant portal for next steps.\n\nCongratulations.\n\nUK Visas and Immigration",
    policy_code: "SW",
    policy_explanation: "All requirements under Appendix Skilled Worker were met.",
    guidance_url: "https://www.gov.uk/skilled-worker-visa",
    sent_at: 35.days.ago },

  # OLGA — refusal letter
  { action_key: "HO-T2-OLGA:Send refusal letter",
    channel: :letter, direction: :outbound,
    subject: "Your visa application HO-T2-OLGA — decision",
    body: "Dear Olga Petrov,\n\nWe regret to inform you that your Skilled Worker visa application (reference: HO-T2-OLGA) has been refused.\n\nReason: Your Certificate of Sponsorship (CoS) is not valid. The sponsoring organisation TechStart Ltd no longer holds a valid UK Visas and Immigration sponsor licence. Under Appendix Skilled Worker, a valid CoS from a licensed sponsor is a mandatory requirement.\n\nYou have the right to an administrative review. Please refer to the enclosed information for details.\n\nUK Visas and Immigration",
    policy_code: "SW-COS",
    policy_explanation: "CoS must be from a currently licensed sponsor per Appendix Skilled Worker.",
    guidance_url: "https://www.gov.uk/skilled-worker-visa/your-job",
    sent_at: 4.days.ago },

  # OLGA — inbound: applicant reply
  { action_key: "HO-T2-OLGA:Send refusal letter",
    channel: :portal, direction: :inbound,
    subject: "Re: Application HO-T2-OLGA — query about refusal",
    body: "I have received your refusal notice. I was not aware that my employer's licence had been revoked. Can I apply again with a new sponsor? Please advise.",
    policy_code: nil,
    policy_explanation: nil,
    guidance_url: nil,
    sent_at: 2.days.ago }
]

correspondence_seeds.each do |attrs|
  action = saved_actions[attrs[:action_key]]
  next unless action

  pr = attrs[:policy_code] ? pr_by_code[attrs[:policy_code]] : nil

  corr = Correspondence.find_or_initialize_by(action: action, subject: attrs[:subject])
  corr.update!(
    channel:            attrs[:channel],
    direction:          attrs[:direction],
    body:               attrs[:body],
    policy_reference:   pr,
    policy_explanation: attrs[:policy_explanation],
    guidance_url:       attrs[:guidance_url],
    sent_at:            attrs[:sent_at]
  )
end
puts "Correspondences: #{Correspondence.count}"
