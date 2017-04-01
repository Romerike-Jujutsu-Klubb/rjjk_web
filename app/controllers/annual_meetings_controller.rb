# frozen_string_literal: true

class AnnualMeetingsController < ApplicationController
  before_action :admin_required

  def index
    @annual_meetings = AnnualMeeting.order(:start_at).reverse_order.all
  end

  def show
    @annual_meeting = AnnualMeeting.find(params[:id])
  end

  def new
    @annual_meeting = AnnualMeeting.new
  end

  def edit
    @annual_meeting = AnnualMeeting.find(params[:id])
  end

  def create
    @annual_meeting = AnnualMeeting.new(params[:annual_meeting])
    if @annual_meeting.save
      redirect_to @annual_meeting, notice: 'Annual meeting was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @annual_meeting = AnnualMeeting.find(params[:id])
    if @annual_meeting.update_attributes(params[:annual_meeting])
      redirect_to @annual_meeting, notice: 'Annual meeting was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @annual_meeting = AnnualMeeting.find(params[:id])
    @annual_meeting.destroy
    redirect_to annual_meetings_url
  end
end
