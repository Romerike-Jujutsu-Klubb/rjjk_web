# frozen_string_literal: true

class AppointmentsController < ApplicationController
  before_action :admin_required

  def index
    @appointments = Appointment.order(:from, :to).reverse_order.to_a
  end

  def show
    @appointment = Appointment.find(params[:id])
  end

  def new
    @appointment ||= Appointment.new
    load_form_data
    render action: :new
  end

  def edit
    @appointment = Appointment.find(params[:id])
    load_form_data
  end

  def create
    @appointment = Appointment.new(params[:appointment])
    if @appointment.save
      redirect_to @appointment, notice: 'Appointment was successfully created.'
    else
      new
    end
  end

  def update
    @appointment = Appointment.find(params[:id])
    if @appointment.update_attributes(params[:appointment])
      redirect_to appointments_path, notice: 'Vervet ble oppdatert.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @appointment = Appointment.find(params[:id])
    @appointment.destroy
    redirect_to appointments_url
  end

  private

  def load_form_data
    @members = Member.order(:first_name, :last_name).to_a
    @roles = Role.order(:name).to_a
  end
end
