# frozen_string_literal: true
class GroupInstructorsController < ApplicationController
  before_action :admin_required

  def index
    group_instructors = GroupInstructor
        .includes(group_semester: :semester, group_schedule: :group)
        .order('group_schedules.weekday, group_schedules.start_at, groups.from_age')
        .to_a
    group_instructors.sort_by! do |gi|
      [
          gi.group_semester.semester.current? ? 0 : 1,
          gi.group_semester.semester.future? ? 0 : 1,
          if gi.group_semester.semester.future?
            gi.group_semester.semester.start_on
          else
            Date.today - gi.group_semester.semester.end_on
          end,
          gi.group_schedule.group.from_age,
          gi.group_schedule.weekday,
          -(gi.member.current_rank.try(:position) || -999),
      ]
    end
    @semesters = group_instructors.group_by { |gi| gi.group_semester.semester }
    return unless Semester.current && !@semesters.include?(Semester.current)
    @semesters = { Semester.current => [] }.update @semesters
  end

  def show
    @group_instructor = GroupInstructor.find(params[:id])
  end

  def new
    @group_instructor ||= GroupInstructor.new params[:group_instructor]
    load_form_data
    render action: :new
  end

  def edit
    @group_instructor ||= GroupInstructor.find(params[:id])
    load_form_data
    render action: :edit
  end

  def create
    convert_semester_id
    @group_instructor = GroupInstructor.new(params[:group_instructor])
    if @group_instructor.save
      redirect_to group_instructors_path, notice: 'GroupInstructor was successfully created.'
    else
      new
    end
  end

  def update
    convert_semester_id
    @group_instructor = GroupInstructor.find(params[:id])
    if @group_instructor.update(params[:group_instructor])
      redirect_to group_instructors_path, notice: 'GroupInstructor was successfully updated.'
    else
      edit
    end
  end

  def destroy
    @group_instructor = GroupInstructor.find(params[:id])
    @group_instructor.destroy
    redirect_to group_instructors_url
  end

  private

  def load_form_data
    @group_schedules ||= GroupSchedule.includes(:group).references(:groups)
        .order('weekday, groups.from_age').to_a.select { |gs| gs.group.active? }
    @group_instructors ||= Member.instructors
    @semesters ||= Semester.order('start_on DESC').limit(10).to_a
  end

  def convert_semester_id
    return unless (semester_id = params[:group_instructor].delete(:semester_id))
    group_schedule = GroupSchedule.find(params[:group_instructor][:group_schedule_id])
    group_semester = GroupSemester.where(group_id: group_schedule.group_id, semester_id: semester_id).first
    params[:group_instructor][:group_semester_id] = group_semester.id
  end
end
