class CasesController < ApplicationController
  before_action :set_case, only: [:show, :edit, :update, :destroy]

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

  private

  def set_case
    @case = Case.find(params[:id])
  end

  def case_params
    params.require(:case).permit(:applicant_name, :applicant_email, :nationality,
                                 :case_type, :status, :priority, :risk_score,
                                 :assigned_to_id, :sla_deadline, :decided_at)
  end
end
