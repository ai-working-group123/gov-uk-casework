class ActionsController < ApplicationController
  before_action :set_case
  before_action :set_action, only: [:show, :edit, :update, :destroy]

  def index
    @actions = @case.actions
  end

  def show
  end

  def new
    @action = @case.actions.new
  end

  def create
    @action = @case.actions.new(action_params)
    if @action.save
      redirect_to case_action_path(@case, @action), notice: "Action was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @action.update(action_params)
      redirect_to case_action_path(@case, @action), notice: "Action was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @action.destroy
    redirect_to case_actions_path(@case), notice: "Action was successfully deleted."
  end

  private

  def set_case
    @case = Case.find(params[:case_id])
  end

  def set_action
    @action = @case.actions.find(params[:id])
  end

  def action_params
    params.require(:action_record).permit(:title, :description, :action_type,
                                          :status, :due_date, :completed_at,
                                          :blocked_by, :policy_reference_id,
                                          :caseworker_guidance)
  end
end
