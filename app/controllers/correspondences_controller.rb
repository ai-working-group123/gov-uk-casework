class CorrespondencesController < ApplicationController
  before_action :set_case_and_action
  before_action :set_correspondence, only: [:show, :edit, :update, :destroy]

  def index
    @correspondences = @action.correspondences
  end

  def show
  end

  def new
    @correspondence = @action.correspondences.new
  end

  def create
    @correspondence = @action.correspondences.new(correspondence_params)
    if @correspondence.save
      redirect_to case_action_correspondence_path(@case, @action, @correspondence), notice: "Correspondence was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @correspondence.update(correspondence_params)
      redirect_to case_action_correspondence_path(@case, @action, @correspondence), notice: "Correspondence was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @correspondence.destroy
    redirect_to case_action_correspondences_path(@case, @action), notice: "Correspondence was successfully deleted."
  end

  private

  def set_case_and_action
    @case = Case.find(params[:case_id])
    @action = @case.actions.find(params[:action_id])
  end

  def set_correspondence
    @correspondence = @action.correspondences.find(params[:id])
  end

  def correspondence_params
    params.require(:correspondence).permit(:channel, :direction, :subject, :body,
                                           :policy_reference_id, :policy_explanation,
                                           :guidance_url, :sent_at)
  end
end
