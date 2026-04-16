class CaseNotesController < ApplicationController
  before_action :set_case
  before_action :set_case_note, only: [:show, :edit, :update, :destroy]

  def index
    @case_notes = @case.case_notes
  end

  def show
  end

  def new
    @case_note = @case.case_notes.new
  end

  def create
    @case_note = @case.case_notes.new(case_note_params)
    if @case_note.save
      redirect_to case_case_note_path(@case, @case_note), notice: "Case note was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @case_note.update(case_note_params)
      redirect_to case_case_note_path(@case, @case_note), notice: "Case note was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @case_note.destroy
    redirect_to case_case_notes_path(@case), notice: "Case note was successfully deleted."
  end

  private

  def set_case
    @case = Case.find(params[:case_id])
  end

  def set_case_note
    @case_note = @case.case_notes.find(params[:id])
  end

  def case_note_params
    params.require(:case_note).permit(:content, :note_type, :caseworker_id,
                                      :visible_to_applicant, :applicant_message)
  end
end
