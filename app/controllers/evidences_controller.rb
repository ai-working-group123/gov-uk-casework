class EvidencesController < ApplicationController
  before_action :set_case
  before_action :set_evidence, only: [ :show, :edit, :update, :destroy ]

  def index
    @evidences = @case.evidences
  end

  def show
  end

  def new
    @evidence = @case.evidences.new
  end

  def create
    @evidence = @case.evidences.new(evidence_params)
    if @evidence.save
      redirect_to case_evidence_path(@case, @evidence), notice: "Evidence was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @evidence.update(evidence_params)
      redirect_to case_evidence_path(@case, @evidence), notice: "Evidence was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @evidence.destroy
    redirect_to case_evidences_path(@case), notice: "Evidence was successfully deleted."
  end

  private

  def set_case
    @case = Case.find(params[:case_id])
  end

  def set_evidence
    @evidence = @case.evidences.find(params[:id])
  end

  def evidence_params
    params.require(:evidence).permit(:evidence_type, :status, :received_at,
                                     :reviewed_at, :notes, :required_by,
                                     :policy_reference_id)
  end
end
