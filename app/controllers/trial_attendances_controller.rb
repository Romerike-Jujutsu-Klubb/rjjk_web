# frozen_string_literal: true
class TrialAttendancesController < ApplicationController
  before_action :admin_required

  # GET /trial_attendances
  # GET /trial_attendances.xml
  def index
    @trial_attendances = TrialAttendance.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @trial_attendances }
    end
  end

  # GET /trial_attendances/1
  # GET /trial_attendances/1.xml
  def show
    @trial_attendance = TrialAttendance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render xml: @trial_attendance }
    end
  end

  # GET /trial_attendances/new
  # GET /trial_attendances/new.xml
  def new
    @trial_attendance = TrialAttendance.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render xml: @trial_attendance }
    end
  end

  # GET /trial_attendances/1/edit
  def edit
    @trial_attendance = TrialAttendance.find(params[:id])
  end

  # POST /trial_attendances
  # POST /trial_attendances.xml
  def create
    if params[:trial_attendance] && params[:trial_attendance][:practice_id]
      practice_id = params[:trial_attendance][:practice_id]
      trial_id = params[:trial_attendance][:nkf_member_trial_id]
    else
      practice_id = Practice
          .where(group_schedule_id: params[:group_schedule_id],
              year: params[:year], week: params[:week])
          .first_or_create!.id
      trial_id = params[:nkf_member_trial_id]
    end
    @trial_attendance = TrialAttendance.new(practice_id: practice_id,
        nkf_member_trial_id: trial_id)

    respond_to do |format|
      if @trial_attendance.save
        format.html do
          if request.xhr?
            render partial: 'attendances/trial_attendance_delete_link',
                locals: { trial_attendance: @trial_attendance }
          else
            redirect_to(@trial_attendance, notice: 'TrialAttendance was successfully created.')
          end
        end
        format.xml { render xml: @trial_attendance, status: :created, location: @trial_attendance }
      else
        format.html { render action: :new }
        format.xml { render xml: @trial_attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /trial_attendances/1
  # PUT /trial_attendances/1.xml
  def update
    @trial_attendance = TrialAttendance.find(params[:id])

    respond_to do |format|
      if @trial_attendance.update_attributes(params[:trial_attendance])
        format.html do
          redirect_to(@trial_attendance, notice: 'TrialAttendance was successfully updated.')
        end
        format.xml { head :ok }
      else
        format.html { render action: :edit }
        format.xml { render xml: @trial_attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @trial_attendance = TrialAttendance.find(params[:id])
    @trial_attendance.destroy

    respond_to do |format|
      format.html do
        if request.xhr?
          render partial: '/attendances/trial_attendance_create_link',
              locals: {
                  nkf_member_trial_id: @trial_attendance.nkf_member_trial_id,
                  group_schedule_id: @trial_attendance.practice.group_schedule_id,
                  date: @trial_attendance.date,
              }
        else
          redirect_to(trial_attendances_url)
        end
      end
      format.xml { head :ok }
    end
  end
end
