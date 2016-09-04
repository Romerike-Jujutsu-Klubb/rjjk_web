# frozen_string_literal: true
class PracticesController < ApplicationController
  before_action :admin_required

  def index
    @practices = Practice.includes(group_schedule: :group).references(:group_schedules)
        .order('year, week, group_schedules.weekday, end_at, start_at, name DESC')
        .reverse_order.to_a

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @practices }
    end
  end

  def show
    @practice = Practice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @practice }
    end
  end

  def new
    @practice = Practice.new
    load_form_data

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @practice }
    end
  end

  def edit
    @practice = Practice.find(params[:id])
    load_form_data
  end

  def create
    @practice = Practice.new(params[:practice])

    respond_to do |format|
      if @practice.save
        format.html do
          redirect_to @practice, notice: 'Scheduled practice was successfully created.'
        end
        format.json { render json: @practice, status: :created, location: @practice }
      else
        format.html { render action: 'new' }
        format.json { render json: @practice.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @practice = Practice.find(params[:id])

    respond_to do |format|
      if @practice.update_attributes(params[:practice])
        format.html do
          redirect_to @practice, notice: 'Scheduled practice was successfully updated.'
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @practice.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @practice = Practice.find(params[:id])
    @practice.destroy

    respond_to do |format|
      format.html { redirect_to practices_url }
      format.json { head :no_content }
    end
  end

  private

  def load_form_data
    @group_schedules = GroupSchedule.includes(:group).references(:groups)
        .order('weekday, start_at, groups.from_age').to_a.select do |gs|
      gs.group.active?(@practice.new_record? ? Date.today : @practice.date)
    end
  end
end
