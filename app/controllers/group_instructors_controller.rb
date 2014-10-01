class GroupInstructorsController < ApplicationController
  before_action :admin_required

  def index
    group_instructors = GroupInstructor.includes(group_semester: :semester, group_schedule: :group).
        order('group_schedules.weekday, group_schedules.start_at, groups.from_age').to_a
    group_instructors.sort_by! { |gi| [gi.group_semester.semester.current? ? 0 : 1, gi.group_semester.semester.future? ? 0 : 1, gi.group_semester.semester.future? ? gi.group_semester.semester.start_on : Date.today - gi.group_semester.semester.end_on] }
    @semesters = group_instructors.group_by { |gi| gi.group_semester.semester }
    if Semester.current && !@semesters.include?(Semester.current)
      @semesters = {Semester.current => []}.update @semesters
    end
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
    @group_instructor = GroupInstructor.new(params[:group_instructor])
    if @group_instructor.save
      redirect_to group_instructors_path, notice: 'GroupInstructor was successfully created.'
    else
      new
    end
  end

  def update
    @group_instructor = GroupInstructor.find(params[:id])
    if @group_instructor.update_attributes(params[:group_instructor])
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
    @group_schedules ||= GroupSchedule.includes(:group).references(:groups).order('weekday, groups.from_age').to_a.select { |gs| gs.group.active? }
    @group_instructors ||= Member.instructors
    @group_semesters ||= GroupSemester.includes(:semester).order('semesters.start_on DESC').to_a
  end

end
