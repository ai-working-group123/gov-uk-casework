class CasesController < ApplicationController
  before_action :set_case, only: [ :show, :edit, :update, :destroy, :evaluate ]

  def index
    @cases = Case.all
  end

  def show
  end

  def new
    @case = Case.new
  end

  def create
    @case = Case.new(case_params)
    if @case.save
      redirect_to @case, notice: "Case was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @case.update(case_params)
      redirect_to @case, notice: "Case was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @case.destroy
    redirect_to cases_path, notice: "Case was successfully deleted."
  end

  # POST /admin/cases/:id/evaluate
  # Evaluates the case against its case type config rules via the LLM rules engine.
  # If apply=true, valid operations are applied immediately.
  # Otherwise, operations are returned as recommendations.
  def evaluate
    engine = CaseRulesEngine.new(@case)

    if params[:apply] == "true"
      @evaluation = engine.evaluate_and_apply!
      redirect_to case_path(@case), notice: "Rules engine applied #{@evaluation[:applied_count]} operation(s)."
    else
      @evaluation = engine.evaluate!
      render :evaluate
    end
  rescue LlmService::Error => e
    redirect_to case_path(@case), alert: "Rules engine error: #{e.message}"
  end

  private

  def set_case
    @case = Case.includes(
      :assigned_to,
      :case_type_config,
      :evidences,
      :case_notes,
      actions: :policy_reference,
      evidences: :policy_reference
    ).find(params[:id])
  end

  def case_params
    params.require(:case).permit(:applicant_name, :applicant_email, :nationality,
                                 :case_type_config_id, :status, :priority, :risk_score,
                                 :assigned_to_id, :sla_deadline, :decided_at)
  end
end
