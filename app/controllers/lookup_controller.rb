class LookupController < ApplicationController
  layout "public"

  def index
  end

  def show
    @case = Case.find_by(reference: params[:reference])
    if @case.nil?
      redirect_to public_lookup_path, alert: "No application found with reference '#{params[:reference]}'. Please check and try again."
    end
  end

  def upload_form
    @case = Case.find_by(reference: params[:reference])
    if @case.nil?
      return redirect_to public_lookup_path, alert: "Application not found."
    end

    @evidence_item = EvidenceRequestItem.find_by(id: params[:item_id])
    # Guard: item must belong to this case
    if @evidence_item && @evidence_item.evidence_request.case_id != @case.id
      @evidence_item = nil
    end
  end

  def upload
    @case = Case.find_by(reference: params[:reference])
    return redirect_to public_lookup_path, alert: "Application not found." if @case.nil?

    @evidence_item = EvidenceRequestItem.find_by(id: params[:item_id])

    # TODO: persist uploaded file (Active Storage / direct upload)
    # For now, mark item as received if present
    if @evidence_item&.pending?
      @evidence_item.update!(status: :received, received_at: Time.current,
                             applicant_note: params[:note].presence)
    end

    redirect_to public_lookup_case_path(reference: @case.reference),
                notice: "Your document has been uploaded successfully."
  end
end
