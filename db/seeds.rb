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

# --- Caseworkers ---

sarah = Caseworker.find_or_create_by!(email: "sarah.chen@homeoffice.gov.uk") do |cw|
	cw.name = "Sarah Chen"
	cw.team = team
	cw.role = :caseworker
	cw.capacity = 15
end

fatima = Caseworker.find_or_create_by!(email: "fatima.ali@homeoffice.gov.uk") do |cw|
	cw.name = "Fatima Ali"
	cw.team = team
	cw.role = :caseworker
	cw.capacity = 15
end

david = Caseworker.find_or_create_by!(email: "david.park@homeoffice.gov.uk") do |cw|
	cw.name = "David Park"
	cw.team = team
	cw.role = :caseworker
	cw.capacity = 15
end

tom = Caseworker.find_or_create_by!(email: "tom.hughes@homeoffice.gov.uk") do |cw|
	cw.name = "Tom Hughes"
	cw.team = team
	cw.role = :caseworker
	cw.capacity = 15
end

nia = Caseworker.find_or_create_by!(email: "nia.williams@homeoffice.gov.uk") do |cw|
	cw.name = "Nia Williams"
	cw.team = team
	cw.role = :caseworker
	cw.capacity = 15
end

# --- Cases ---

demo_cases = [
	{
		applicant_name: "Priya Sharma",
		applicant_email: "priya.sharma@example.com",
		nationality: "Indian",
		status: :awaiting_evidence,
		priority: :urgent,
		risk_score: 85,
		assigned_to: sarah,
		submitted_at: 71.days.ago,
		assigned_at: 70.days.ago,
		sla_deadline: 13.days.ago
	},
	{
		applicant_name: "Marco Rossi",
		applicant_email: "marco.rossi@example.com",
		nationality: "Italian",
		status: :in_review,
		priority: :medium,
		risk_score: 30,
		assigned_to: sarah,
		submitted_at: 20.days.ago,
		assigned_at: 19.days.ago,
		sla_deadline: 36.days.from_now
	},
	{
		applicant_name: "Aisha Hassan",
		applicant_email: "aisha.hassan@example.com",
		nationality: "Sudanese",
		status: :in_review,
		priority: :medium,
		risk_score: 15,
		assigned_to: fatima,
		submitted_at: 30.days.ago,
		assigned_at: 29.days.ago,
		sla_deadline: 26.days.from_now
	},
	{
		applicant_name: "James O'Brien",
		applicant_email: "james.obrien@example.com",
		nationality: "Irish",
		status: :submitted,
		priority: :low,
		risk_score: 5,
		assigned_to: david,
		submitted_at: Time.current,
		assigned_at: Time.current,
		sla_deadline: 56.days.from_now
	},
	{
		applicant_name: "Li Wei",
		applicant_email: "li.wei@example.com",
		nationality: "Chinese",
		status: :in_review,
		priority: :high,
		risk_score: 70,
		assigned_to: fatima,
		submitted_at: 90.days.ago,
		assigned_at: 88.days.ago,
		sla_deadline: 34.days.ago
	},
	{
		applicant_name: "Elena Vasquez",
		applicant_email: "elena.vasquez@example.com",
		nationality: "Colombian",
		status: :awaiting_evidence,
		priority: :medium,
		risk_score: 40,
		assigned_to: fatima,
		submitted_at: 45.days.ago,
		assigned_at: 44.days.ago,
		sla_deadline: 5.days.from_now
	},
	{
		applicant_name: "Yuki Tanaka",
		applicant_email: "yuki.tanaka@example.com",
		nationality: "Japanese",
		status: :ready_for_decision,
		priority: :low,
		risk_score: 10,
		assigned_to: david,
		submitted_at: 40.days.ago,
		assigned_at: 39.days.ago,
		sla_deadline: 16.days.from_now
	},
	{
		applicant_name: "Ahmed Osman",
		applicant_email: "ahmed.osman@example.com",
		nationality: "Egyptian",
		status: :assigned,
		priority: :medium,
		risk_score: 20,
		assigned_to: tom,
		submitted_at: 5.days.ago,
		assigned_at: 4.days.ago,
		sla_deadline: 51.days.from_now
	},
	{
		applicant_name: "Sofia Andersson",
		applicant_email: "sofia.andersson@example.com",
		nationality: "Swedish",
		status: :decided_approved,
		priority: :low,
		risk_score: 0,
		assigned_to: sarah,
		submitted_at: 60.days.ago,
		assigned_at: 59.days.ago,
		sla_deadline: 4.days.ago,
		decided_at: 10.days.ago
	},
	{
		applicant_name: "Kwame Mensah",
		applicant_email: "kwame.mensah@example.com",
		nationality: "Ghanaian",
		status: :awaiting_evidence,
		priority: :high,
		risk_score: 55,
		assigned_to: nia,
		submitted_at: 50.days.ago,
		assigned_at: 49.days.ago,
		sla_deadline: 6.days.from_now
	}
]

demo_cases.each do |attrs|
	Case.find_or_create_by!(applicant_name: attrs[:applicant_name]) do |kase|
		kase.case_type_config = case_type_config
		kase.applicant_email = attrs[:applicant_email]
		kase.nationality = attrs[:nationality]
		kase.status = attrs[:status]
		kase.priority = attrs[:priority]
		kase.risk_score = attrs[:risk_score]
		kase.assigned_to = attrs[:assigned_to]
		kase.submitted_at = attrs[:submitted_at]
		kase.assigned_at = attrs[:assigned_at]
		kase.sla_deadline = attrs[:sla_deadline]
		kase.decided_at = attrs[:decided_at]
	end
end
