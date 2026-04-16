class LookupController < ApplicationController
  def index
  end

  def show
    @case = Case.find_by(reference: params[:reference])
    if @case.nil?
      redirect_to public_lookup_path, alert: "No case found with reference: #{params[:reference]}"
    end
  end
end
