class BoardMeetingsController < ApplicationController
  before_filter :admin_required

  def index
    @board_meetings = BoardMeeting.order(:start_at).reverse_order.all
    load_form_data
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @board_meetings }
    end
  end

  def show
    @board_meeting = BoardMeeting.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @board_meeting }
    end
  end

  def new
    load_form_data
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @board_meeting }
    end
  end

  def edit
    @board_meeting = BoardMeeting.find(params[:id])
    load_form_data
  end

  def create
    @board_meeting = BoardMeeting.new(params[:board_meeting])
    respond_to do |format|
      if @board_meeting.save
        format.html { redirect_to board_meetings_path, notice: 'Board meeting was successfully created.' }
        format.json { render json: @board_meeting, status: :created, location: @board_meeting }
      else
        format.html { render :new }
        format.json { render json: @board_meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @board_meeting = BoardMeeting.find(params[:id])
    respond_to do |format|
      if @board_meeting.update_attributes(params[:board_meeting])
        format.html { redirect_to board_meetings_path, notice: 'Board meeting was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @board_meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @board_meeting = BoardMeeting.find(params[:id])
    @board_meeting.destroy
    respond_to do |format|
      format.html { redirect_to board_meetings_url }
      format.json { head :no_content }
    end
  end

  def minutes
    bm = BoardMeeting.find(params[:id])
    send_data bm.minutes_content_data, type: bm.minutes_content_type,
        filename: bm.minutes_filename, disposition: 'attachment'
  end

  private

  def load_form_data
    @board_meeting ||= BoardMeeting.new params[:board_meeting]
    @annual_meetings = AnnualMeeting.order('start_at DESC').to_a
  end
end
