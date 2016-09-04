# frozen_string_literal: true
class AppointmentsController < ApplicationController
  before_action :admin_required

  def index
    @appointments = Appointment.all
  end

  def show
    @appointment = Appointment.find(params[:id])
  end

  def new
    @appointment = Appointment.new
  end

  def edit
    @appointment = Appointment.find(params[:id])
  end

  def create
    @appointment = Appointment.new(params[:appointment])
    if @appointment.save
      redirect_to @appointment, notice: 'Appointment was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @appointment = Appointment.find(params[:id])
    if @appointment.update_attributes(params[:appointment])
      redirect_to @appointment, notice: 'Appointment was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @appointment = Appointment.find(params[:id])
    @appointment.destroy
    redirect_to appointments_url
  end
end
