class AnnualMeetingsController < ApplicationController
  # GET /annual_meetings
  # GET /annual_meetings.json
  def index
    @annual_meetings = AnnualMeeting.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @annual_meetings }
    end
  end

  # GET /annual_meetings/1
  # GET /annual_meetings/1.json
  def show
    @annual_meeting = AnnualMeeting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @annual_meeting }
    end
  end

  # GET /annual_meetings/new
  # GET /annual_meetings/new.json
  def new
    @annual_meeting = AnnualMeeting.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @annual_meeting }
    end
  end

  # GET /annual_meetings/1/edit
  def edit
    @annual_meeting = AnnualMeeting.find(params[:id])
  end

  # POST /annual_meetings
  # POST /annual_meetings.json
  def create
    @annual_meeting = AnnualMeeting.new(params[:annual_meeting])

    respond_to do |format|
      if @annual_meeting.save
        format.html { redirect_to @annual_meeting, notice: 'Annual meeting was successfully created.' }
        format.json { render json: @annual_meeting, status: :created, location: @annual_meeting }
      else
        format.html { render action: "new" }
        format.json { render json: @annual_meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /annual_meetings/1
  # PUT /annual_meetings/1.json
  def update
    @annual_meeting = AnnualMeeting.find(params[:id])

    respond_to do |format|
      if @annual_meeting.update_attributes(params[:annual_meeting])
        format.html { redirect_to @annual_meeting, notice: 'Annual meeting was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @annual_meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /annual_meetings/1
  # DELETE /annual_meetings/1.json
  def destroy
    @annual_meeting = AnnualMeeting.find(params[:id])
    @annual_meeting.destroy

    respond_to do |format|
      format.html { redirect_to annual_meetings_url }
      format.json { head :no_content }
    end
  end
end
