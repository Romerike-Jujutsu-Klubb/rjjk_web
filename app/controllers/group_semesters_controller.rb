# frozen_string_literal: true

class GroupSemestersController < ApplicationController
  before_action :admin_required, except: :show
  before_action :authenticate_user, only: :show

  def index
    @group_semesters = GroupSemester.includes(:semester).order('semesters.start_on DESC').to_a
  end

  def show
    @group_semester = GroupSemester.includes(group: :group_schedules).find(params[:id])
  end

  def new
    @group_semester ||= GroupSemester.new params[:group_semester]
    load_form_data
    render action: :new
  end

  def edit
    @group_semester ||= GroupSemester.find(params[:id])
    load_form_data
  end

  def create
    @group_semester = GroupSemester.new(params[:group_semester])
    if @group_semester.save
      create_practices
      redirect_to @group_semester, notice: 'Group semester was successfully created.'
    else
      new
    end
  end

  def update
    @group_semester = GroupSemester.find(params[:id])
    if @group_semester.update(params[:group_semester])
      create_practices
      redirect_to @group_semester, notice: 'Semesterplan er lagret'
    else
      edit
      render action: 'edit'
    end
  end

  def destroy
    @group_semester = GroupSemester.find(params[:id])
    @group_semester.destroy
    redirect_to group_semesters_url
  end

  private

  def load_form_data
    @groups = Group.active(@group_semester.semester.try(:start_on) || Date.current)
        .order(:from_age).to_a
    @semesters = Semester.order('start_on DESC').to_a
    @instructors = Member
        .instructors(@group_semester.first_session || @group_semester.semester.try(:start_on))
        .to_a
        .sort_by(&:current_rank).reverse
  end

  def create_practices
    return unless @group_semester.first_session && @group_semester.last_session

    schedules = @group_semester.group.group_schedules
    (@group_semester.first_session..@group_semester.last_session).each do |date|
      if (gs = schedules.find { |grsc| grsc.weekday == date.cwday })
        Practice.where(group_schedule_id: gs.id, year: date.year, week: date.cweek).first_or_create!
      end
    end
  end
end
