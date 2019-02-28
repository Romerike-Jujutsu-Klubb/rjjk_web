# frozen_string_literal: true

class AttendanceWebpushesController < ApplicationController
  before_action :authenticate_user
  before_action :set_attendance_webpush, only: %i[show edit update destroy]

  def index
    @attendance_webpushes = AttendanceWebpush.all
  end

  def show; end

  def new
    @attendance_webpush = AttendanceWebpush.new
  end

  def edit; end

  def create
    @attendance_webpush = AttendanceWebpush.new(attendance_webpush_params)
    if @attendance_webpush.save
      redirect_to @attendance_webpush, notice: 'Attendance webpush was successfully created.'
    else
      render :new
    end
  end

  def update
    if @attendance_webpush.update(attendance_webpush_params)
      redirect_to @attendance_webpush, notice: 'Attendance webpush was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @attendance_webpush.destroy
    redirect_to attendance_webpushes_url, notice: 'Attendance webpush was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_attendance_webpush
    @attendance_webpush = AttendanceWebpush.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def attendance_webpush_params
    params.require(:attendance_webpush).permit(:member_id, :endpoint, :p256dh, :auth)
  end
end
