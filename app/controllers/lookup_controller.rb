class LookupController < ApplicationController
  layout "public"

  def index
  end

  def show
    @reference = params[:reference]
  end

  def upload_form
    @reference = params[:reference]
    @item_id   = params[:item_id]
  end

  def upload
    redirect_to lookup_case_path(params[:reference])
  end
end
