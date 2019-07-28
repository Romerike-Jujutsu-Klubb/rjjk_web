# frozen_string_literal: true

class InstructorMeetingsController < ApplicationController
  before_action :set_instructor_meeting, only: %i[show edit update destroy]

  def index
    @instructor_meetings = InstructorMeeting.order(start_at: :desc, end_at: :desc).to_a
  end

  def show; end

  def new
    @instructor_meeting = InstructorMeeting.new
  end

  def edit; end

  def create
    @instructor_meeting = InstructorMeeting.new(instructor_meeting_params)
    if @instructor_meeting.save
      redirect_to instructor_meetings_path, notice: 'Ny instruktørsamling ble opprettet.'
    else
      render :new
    end
  end

  def update
    if @instructor_meeting.update(instructor_meeting_params)
      redirect_to instructor_meetings_path, notice: 'Instruktørsamlingen ble oppdatert.'
    else
      render :edit
    end
  end

  def destroy
    @instructor_meeting.destroy
    redirect_to instructor_meetings_url, notice: 'Instruktørsamlingen ble slettet.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_instructor_meeting
    @instructor_meeting = InstructorMeeting.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def instructor_meeting_params
    params.require(:instructor_meeting).permit(:description, :end_at, :name, :start_at)
  end
end
