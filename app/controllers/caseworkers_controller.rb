class CaseworkersController < ApplicationController
  before_action :set_caseworker, only: [ :show, :edit, :update, :destroy ]

  def index
    @caseworkers = Caseworker.all
  end

  def show
  end

  def new
    @caseworker = Caseworker.new
  end

  def create
    @caseworker = Caseworker.new(caseworker_params)
    if @caseworker.save
      redirect_to @caseworker, notice: "Caseworker was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @caseworker.update(caseworker_params)
      redirect_to @caseworker, notice: "Caseworker was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @caseworker.destroy
    redirect_to caseworkers_path, notice: "Caseworker was successfully deleted."
  end

  private

  def set_caseworker
    @caseworker = Caseworker.find(params[:id])
  end

  def caseworker_params
    params.require(:caseworker).permit(:name, :email, :team_id, :capacity)
  end
end
