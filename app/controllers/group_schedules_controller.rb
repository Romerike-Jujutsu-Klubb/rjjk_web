# frozen_string_literal: true

class GroupSchedulesController < ApplicationController
  before_action :admin_required

  def index
    @group_schedules = GroupSchedule.all.to_a
        .select { |gs| gs.group.active? }
        .sort_by do |gs|
      [gs.weekday.zero? ? 7 : gs.weekday, gs.start_at, gs.end_at, gs.group.from_age]
    end
    respond_to do |format|
      format.html
      format.xml { render xml: @group_schedules }
    end
  end

  def yaml
    @group_schedules = GroupSchedule.all
    render text: @group_schedules.map(&:attributes).to_yaml,
           content_type: 'text/yaml', layout: false
  end

  def show
    @group_schedule = GroupSchedule.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render xml: @group_schedule }
    end
  end

  def new
    @group_schedule ||= GroupSchedule.new
    @groups = Group.all

    respond_to do |format|
      format.html { render action: :new }
      format.xml { render xml: @group_schedule }
    end
  end

  def edit
    @group_schedule = GroupSchedule.find(params[:id])
    @groups = Group.all
  end

  def create
    @group_schedule = GroupSchedule.new(params[:group_schedule])

    respond_to do |format|
      if @group_schedule.save
        flash[:notice] = 'GroupSchedule was successfully created.'
        format.html { redirect_to(@group_schedule) }
        format.xml { render xml: @group_schedule, status: :created, location: @group_schedule }
      else
        format.html { new }
        format.xml { render xml: @group_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @group_schedule = GroupSchedule.find(params[:id])

    respond_to do |format|
      if @group_schedule.update_attributes(params[:group_schedule])
        flash[:notice] = 'GroupSchedule was successfully updated.'
        format.html { redirect_to group_schedules_path }
        format.xml { head :ok }
      else
        format.html { render action: :edit }
        format.xml { render xml: @group_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @group_schedule = GroupSchedule.find(params[:id])
    @group_schedule.destroy

    respond_to do |format|
      format.html { redirect_to(group_schedules_url) }
      format.xml { head :ok }
    end
  end
end
