class PolicyReferencesController < ApplicationController
  before_action :set_policy_reference, only: [:show, :edit, :update, :destroy]

  def index
    @policy_references = PolicyReference.all
  end

  def show
  end

  def new
    @policy_reference = PolicyReference.new
  end

  def create
    @policy_reference = PolicyReference.new(policy_reference_params)
    if @policy_reference.save
      redirect_to @policy_reference, notice: "Policy reference was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @policy_reference.update(policy_reference_params)
      redirect_to @policy_reference, notice: "Policy reference was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @policy_reference.destroy
    redirect_to policy_references_path, notice: "Policy reference was successfully deleted."
  end

  private

  def set_policy_reference
    @policy_reference = PolicyReference.find(params[:id])
  end

  def policy_reference_params
    params.require(:policy_reference).permit(:code, :parent_code, :title, :policy_area,
                                             :case_types, :summary, :criteria, :govuk_url,
                                             :legislation_url, :internal_guidance_url,
                                             :applicant_summary, :applicant_url)
  end
end
