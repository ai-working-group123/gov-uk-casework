class EvidenceRequestItemsController < ApplicationController
  before_action :set_case_and_evidence_request
  before_action :set_evidence_request_item, only: [:show, :edit, :update, :destroy]

  def index
    @evidence_request_items = @evidence_request.evidence_request_items
  end

  def show
  end

  def new
    @evidence_request_item = @evidence_request.evidence_request_items.new
  end

  def create
    @evidence_request_item = @evidence_request.evidence_request_items.new(evidence_request_item_params)
    if @evidence_request_item.save
      redirect_to case_evidence_request_evidence_request_item_path(@case, @evidence_request, @evidence_request_item),
                  notice: "Evidence request item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @evidence_request_item.update(evidence_request_item_params)
      redirect_to case_evidence_request_evidence_request_item_path(@case, @evidence_request, @evidence_request_item),
                  notice: "Evidence request item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @evidence_request_item.destroy
    redirect_to case_evidence_request_evidence_request_items_path(@case, @evidence_request),
                notice: "Evidence request item was successfully deleted."
  end

  private

  def set_case_and_evidence_request
    @case = Case.find(params[:case_id])
    @evidence_request = @case.evidence_requests.find(params[:evidence_request_id])
  end

  def set_evidence_request_item
    @evidence_request_item = @evidence_request.evidence_request_items.find(params[:id])
  end

  def evidence_request_item_params
    params.require(:evidence_request_item).permit(:evidence_id, :policy_reference_id,
                                                  :submission_method, :reason, :status,
                                                  :upload_content_type, :upload_file_size,
                                                  :received_at, :applicant_note)
  end
end
