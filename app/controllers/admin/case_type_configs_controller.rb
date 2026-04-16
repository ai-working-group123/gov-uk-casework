module Admin
  class CaseTypeConfigsController < ApplicationController
    layout "admin"

    before_action :set_case_type_config, only: [
      :show, :questions, :answer, :review, :submit_review,
      :suggestions, :apply_suggestions, :finalise, :publish,
      :processing, :generate
    ]

    def index
      @case_type_configs = CaseTypeConfig.order(created_at: :desc)
    end

    def new
      @case_type_config = CaseTypeConfig.new
    end

    # POST /admin/case_type_configs
    # Receives description + URLs, kicks off scrape & analyse in background
    def create
      @case_type_config = CaseTypeConfig.new(
        name: "Untitled — Generating...",
        slug: "draft-#{SecureRandom.hex(6)}",
        description: params[:description],
        decision_tree_md: "",
        state_transitions_md: "",
        source_metadata: {
          source_type: params[:urls].present? ? "url" : "description",
          urls: Array(params[:urls]).reject(&:blank?),
          description: params[:description],
          submitted_at: Time.current.iso8601
        },
        status: :draft
      )

      if @case_type_config.save
        # Run scrape & analyse synchronously (stub sleeps 5s)
        generator = ::CaseTypeGeneratorStub.new
        result = generator.scrape_and_analyse!(
          description: params[:description],
          urls: Array(params[:urls]).reject(&:blank?)
        )

        # Store analysis result in generation log
        @case_type_config.case_type_generation_logs.create!(
          step: 2,
          step_name: "analyse",
          input_text: params[:description],
          output_text: result.to_json,
          confidence_score: 0.5
        )

        # Store conversation state in session
        session["ctc_#{@case_type_config.id}_conversation_id"] = result[:conversation_id]
        session["ctc_#{@case_type_config.id}_questions"] = result[:questions].to_json

        redirect_to questions_admin_case_type_config_path(@case_type_config)
      else
        render :new, status: :unprocessable_entity
      end
    end

    # GET /admin/case_type_configs/:id/questions
    def questions
      questions_json = session["ctc_#{@case_type_config.id}_questions"]
      @questions = questions_json ? JSON.parse(questions_json, symbolize_names: true) : []
      @conversation_id = session["ctc_#{@case_type_config.id}_conversation_id"]
    end

    # POST /admin/case_type_configs/:id/answer
    # Receives answers to clarifying questions, triggers generation
    def answer
      conversation_id = session["ctc_#{@case_type_config.id}_conversation_id"]

      # Build answers text block from form params
      answers = params[:answers]&.to_unsafe_h || {}
      answers_text = answers.map { |qid, answer_data|
        question_text = answer_data[:question]
        response = if answer_data[:skip] == "1"
          "I don't know — use your best judgement"
        elsif answer_data[:custom].present?
          answer_data[:custom]
        else
          answer_data[:selected]
        end
        "Q: #{question_text}\nA: #{response}"
      }.join("\n\n")

      # Log the answers
      @case_type_config.case_type_generation_logs.create!(
        step: 2,
        step_name: "clarifying_answers",
        input_text: answers_text,
        output_text: "",
        confidence_score: 0.8
      )

      # Run generation (stub sleeps 5s)
      generator = ::CaseTypeGeneratorStub.new
      result = generator.generate_config!(
        conversation_id: conversation_id,
        answers_text: answers_text
      )

      # Update the case type config with generated content
      @case_type_config.update!(
        name: result[:name],
        slug: result[:slug],
        description: result[:description],
        default_sla_days: result[:default_sla_days],
        decision_tree_md: result[:decision_tree_md],
        state_transitions_md: result[:state_transitions_md],
        evidence_requirements_md: result[:evidence_requirements_md],
        risk_scoring_md: result[:risk_scoring_md],
        correspondence_templates_md: result[:correspondence_templates_md]
      )

      # Log the generation
      @case_type_config.case_type_generation_logs.create!(
        step: 3,
        step_name: "generate",
        input_text: answers_text,
        output_text: result.to_json,
        confidence_score: 0.9
      )

      # Clean up session
      session.delete("ctc_#{@case_type_config.id}_conversation_id")
      session.delete("ctc_#{@case_type_config.id}_questions")

      redirect_to review_admin_case_type_config_path(@case_type_config)
    end

    # GET /admin/case_type_configs/:id/review
    def review
    end

    # POST /admin/case_type_configs/:id/submit_review
    # Saves edited markdown sections, then kicks off improvement suggestions
    def submit_review
      @case_type_config.update!(
        decision_tree_md: params[:decision_tree_md],
        state_transitions_md: params[:state_transitions_md],
        evidence_requirements_md: params[:evidence_requirements_md],
        risk_scoring_md: params[:risk_scoring_md],
        correspondence_templates_md: params[:correspondence_templates_md]
      )

      # Run improvement suggestions (stub sleeps 5s)
      generator = ::CaseTypeGeneratorStub.new
      result = generator.suggest_improvements!(case_type_config: @case_type_config)

      # Create suggestion records
      result[:suggestions].each do |suggestion|
        @case_type_config.case_type_suggestions.create!(
          title: suggestion[:title],
          description: suggestion[:description],
          category: suggestion[:category],
          priority: suggestion[:priority],
          impact_description: suggestion[:impact_description],
          standard_reference: suggestion[:standard_reference]
        )
      end

      # Log the suggestions step
      @case_type_config.case_type_generation_logs.create!(
        step: 4,
        step_name: "suggest_improvements",
        input_text: @case_type_config.attributes.slice(
          "decision_tree_md", "state_transitions_md", "evidence_requirements_md",
          "risk_scoring_md", "correspondence_templates_md"
        ).to_json,
        output_text: result.to_json,
        confidence_score: 0.85
      )

      redirect_to suggestions_admin_case_type_config_path(@case_type_config)
    end

    # GET /admin/case_type_configs/:id/suggestions
    def suggestions
      @suggestions = @case_type_config.case_type_suggestions.where(status: :suggested).order(:priority)
    end

    # POST /admin/case_type_configs/:id/apply_suggestions
    # Processes accepted/rejected suggestions and applies them via LLM
    def apply_suggestions
      accepted_ids = []
      comments = {}

      (params[:suggestions] || {}).each do |suggestion_id, data|
        suggestion = @case_type_config.case_type_suggestions.find(suggestion_id)
        if data[:accepted] == "1"
          suggestion.update!(status: :accepted)
          accepted_ids << suggestion_id
        else
          suggestion.update!(status: :rejected)
        end
        comments[suggestion_id] = data[:comment] if data[:comment].present?
      end

      if accepted_ids.any?
        # Run LLM to apply accepted suggestions (stub sleeps 5s)
        generator = ::CaseTypeGeneratorStub.new
        accepted = @case_type_config.case_type_suggestions.where(id: accepted_ids)
        result = generator.apply_suggestions!(
          case_type_config: @case_type_config,
          accepted_suggestions: accepted,
          comments: comments
        )

        # Log the apply step
        @case_type_config.case_type_generation_logs.create!(
          step: 5,
          step_name: "apply_suggestions",
          input_text: accepted.map(&:title).join(", "),
          output_text: result.to_json,
          confidence_score: 0.9
        )
      end

      redirect_to finalise_admin_case_type_config_path(@case_type_config)
    end

    # GET /admin/case_type_configs/:id/finalise
    def finalise
    end

    # POST /admin/case_type_configs/:id/publish
    def publish
      @case_type_config.update!(status: :published)
      redirect_to admin_case_type_configs_path, notice: "\"#{@case_type_config.name}\" has been published."
    end

    # GET /admin/case_type_configs/:id/processing
    def processing
    end

    # POST /admin/case_type_configs/:id/generate
    def generate
    end

    # GET /admin/case_type_configs/:id
    def show
    end

    private

    def set_case_type_config
      @case_type_config = CaseTypeConfig.find(params[:id])
    end
  end
end
