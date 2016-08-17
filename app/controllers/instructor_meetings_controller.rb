class InstructorMeetingsController < ApplicationController
  before_action :set_instructor_meeting, only: [:show, :edit, :update, :destroy]

  # GET /instructor_meetings
  # GET /instructor_meetings.json
  def index
    @instructor_meetings = InstructorMeeting.all
  end

  # GET /instructor_meetings/1
  # GET /instructor_meetings/1.json
  def show
  end

  # GET /instructor_meetings/new
  def new
    @instructor_meeting = InstructorMeeting.new
  end

  # GET /instructor_meetings/1/edit
  def edit
  end

  # POST /instructor_meetings
  # POST /instructor_meetings.json
  def create
    @instructor_meeting = InstructorMeeting.new(instructor_meeting_params)

    respond_to do |format|
      if @instructor_meeting.save
        format.html { redirect_to @instructor_meeting, notice: 'Instructor meeting was successfully created.' }
        format.json { render :show, status: :created, location: @instructor_meeting }
      else
        format.html { render :new }
        format.json { render json: @instructor_meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instructor_meetings/1
  # PATCH/PUT /instructor_meetings/1.json
  def update
    respond_to do |format|
      if @instructor_meeting.update(instructor_meeting_params)
        format.html { redirect_to @instructor_meeting, notice: 'Instructor meeting was successfully updated.' }
        format.json { render :show, status: :ok, location: @instructor_meeting }
      else
        format.html { render :edit }
        format.json { render json: @instructor_meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instructor_meetings/1
  # DELETE /instructor_meetings/1.json
  def destroy
    @instructor_meeting.destroy
    respond_to do |format|
      format.html { redirect_to instructor_meetings_url, notice: 'Instructor meeting was successfully destroyed.' }
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
