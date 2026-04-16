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
		case_types: "skilled-worker-visa",
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
		case_types: "skilled-worker-visa",
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
		case_types: "skilled-worker-visa",
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
		case_types: "skilled-worker-visa",
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
		case_types: "skilled-worker-visa",
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
		case_types: "skilled-worker-visa",
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
		case_types: "skilled-worker-visa",
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
		case_types: "skilled-worker-visa",
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
		case_types: "skilled-worker-visa",
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
		case_types: "skilled-worker-visa",
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
		case_type_config: case_type_config,
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
