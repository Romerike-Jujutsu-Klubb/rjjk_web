# frozen_string_literal: true

class PracticesController < ApplicationController
  before_action :admin_required

  def index
    @practices = Practice.includes(group_schedule: :group).references(:group_schedules)
        .order('year, week, group_schedules.weekday, end_at, start_at, name DESC')
        .reverse_order.to_a
  end

  def show
    @practice = Practice.find(params[:id])
  end

  def new
    @practice = Practice.new
    load_form_data
  end

  def edit
    @practice = Practice.find(params[:id])
    load_form_data
  end

  def create
    @practice = Practice.new(params[:practice])
    if @practice.save
      redirect_to practices_path, notice: 'Scheduled practice was successfully created.'
    else
      render :new
    end
  end

  def update
    @practice = Practice.find(params[:id])
    if @practice.update(params[:practice])
      if request.xhr?
        render plain: ''
      else
        redirect_to @practice.group_semester || @practice, notice: 'Treningen er oppdatert.'
      end
    else
      render :edit
    end
  end

  def destroy
    @practice = Practice.find(params[:id])
    @practice.destroy
    redirect_to practices_url
  end

  private

  def load_form_data
    @group_schedules = GroupSchedule.includes(:group).references(:groups)
        .order('weekday, start_at, groups.from_age').to_a.select do |gs|
      gs.group.active?(@practice.new_record? ? Date.current : @practice.date)
    end
  end
end
