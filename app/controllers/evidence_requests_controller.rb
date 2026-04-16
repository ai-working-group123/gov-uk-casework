class EvidenceRequestsController < ApplicationController
  before_action :set_case
  before_action :set_evidence_request, only: [:show, :edit, :update, :destroy]

  def index
    @evidence_requests = @case.evidence_requests
  end

  def show
  end

  def new
    @evidence_request = @case.evidence_requests.new
  end

  def create
    @evidence_request = @case.evidence_requests.new(evidence_request_params)
    if @evidence_request.save
      redirect_to case_evidence_request_path(@case, @evidence_request), notice: "Evidence request was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @evidence_request.update(evidence_request_params)
      redirect_to case_evidence_request_path(@case, @evidence_request), notice: "Evidence request was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @evidence_request.destroy
    redirect_to case_evidence_requests_path(@case), notice: "Evidence request was successfully deleted."
  end

  private

  def set_case
    @case = Case.find(params[:case_id])
  end

  def set_evidence_request
    @evidence_request = @case.evidence_requests.find(params[:id])
  end

  def evidence_request_params
    params.require(:evidence_request).permit(:requested_by_id, :status, :deadline,
                                             :notify_via, :cover_message, :sent_at,
                                             :reminder_sent_at)
  end
end
