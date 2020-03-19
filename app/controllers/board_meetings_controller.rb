# frozen_string_literal: true

class BoardMeetingsController < ApplicationController
  before_action :admin_required

  def index
    @board_meetings = BoardMeeting.order(:start_at).reverse_order.all
    load_form_data
  end

  def show
    @board_meeting = BoardMeeting.find(params[:id])
  end

  def new
    load_form_data
  end

  def edit
    @board_meeting = BoardMeeting.find(params[:id])
    load_form_data
  end

  def create
    @board_meeting = BoardMeeting.new(params[:board_meeting])
    if @board_meeting.save
      redirect_to board_meetings_path, notice: 'Board meeting was successfully created.'
    else
      render :new
    end
  end

  def update
    @board_meeting = BoardMeeting.find(params[:id])
    parameters = params[:board_meeting]
    if parameters && @board_meeting.update(parameters)
      redirect_to board_meetings_path, notice: 'Board meeting was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @board_meeting = BoardMeeting.find(params[:id])
    @board_meeting.destroy
    redirect_to board_meetings_url
  end

  def minutes
    bm = BoardMeeting.find(params[:id])
    send_data bm.minutes_content_data, type: bm.minutes_content_type,
                                       filename: bm.minutes_filename, disposition: 'attachment'
  end

  private

  def load_form_data
    @board_meeting ||= BoardMeeting.new params[:board_meeting]
  end
end
