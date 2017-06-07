# frozen_string_literal: true

class InstructorMeetingsController < ApplicationController
  before_action :set_instructor_meeting, only: %i[show edit update destroy]

  def index
    @instructor_meetings = InstructorMeeting.all
  end

  def show; end

  def new
    @instructor_meeting = InstructorMeeting.new
  end

  def edit; end

  def create
    @instructor_meeting = InstructorMeeting.new(instructor_meeting_params)

    respond_to do |format|
      if @instructor_meeting.save
        format.html do
          redirect_to @instructor_meeting, notice: 'Instructor meeting was successfully created.'
        end
        format.json { render :show, status: :created, location: @instructor_meeting }
      else
        format.html { render :new }
        format.json { render json: @instructor_meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @instructor_meeting.update(instructor_meeting_params)
        format.html do
          redirect_to @instructor_meeting, notice: 'Instructor meeting was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @instructor_meeting }
      else
        format.html { render :edit }
        format.json { render json: @instructor_meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @instructor_meeting.destroy
    respond_to do |format|
      format.html do
        redirect_to instructor_meetings_url,
            notice: 'Instructor meeting was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_instructor_meeting
    @instructor_meeting = InstructorMeeting.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def instructor_meeting_params
    params.require(:instructor_meeting).permit(:start_at, :end_at, :title, :agenda)
  end
end
