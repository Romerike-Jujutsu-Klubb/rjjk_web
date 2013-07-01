class GroupInstructorsController < ApplicationController
  # GET /group_instructors
  # GET /group_instructors.json
  def index
    group_instructors = GroupInstructor.includes(:semester, :group_schedule => :group).
        order('group_schedules.weekday, group_schedules.start_at, groups.from_age').all
    group_instructors.sort_by!{|gi| [gi.semester.current? ? 0 : 1, gi.semester.future? ? 0 : 1, gi.semester.future? ? gi.semester.start_on : Date.today - gi.semester.end_on]}
    @semesters = group_instructors.group_by(&:semester)
    if @semesters.empty? && Semester.current
      @semesters = {Semester.current => []}
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @group_instructors }
    end
  end

  # GET /group_instructors/1
  # GET /group_instructors/1.json
  def show
    @group_instructor = GroupInstructor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group_instructor }
    end
  end

  def new
    @group_instructor ||= GroupInstructor.new params[:group_instructor]
    load_form_data

    respond_to do |format|
      format.html { render action: :new }
      format.json { render json: @group_instructor }
    end
  end

  # GET /group_instructors/1/edit
  def edit
    @group_instructor = GroupInstructor.find(params[:id])
    load_form_data
  end

  # POST /group_instructors
  # POST /group_instructors.json
  def create
    @group_instructor = GroupInstructor.new(params[:group_instructor])

    respond_to do |format|
      if @group_instructor.save
        format.html { redirect_to @group_instructor, notice: 'GroupInstructor was successfully created.' }
        format.json { render json: @group_instructor, status: :created, location: @group_instructor }
      else
        format.html { new }
        format.json { render json: @group_instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /group_instructors/1
  # PUT /group_instructors/1.json
  def update
    @group_instructor = GroupInstructor.find(params[:id])

    respond_to do |format|
      if @group_instructor.update_attributes(params[:group_instructor])
        format.html { redirect_to group_instructors_path, notice: 'GroupInstructor was successfully updated.' }
        format.json { head :no_content }
      else
        @groups = Group.all
        @group_instructors = Member.instructors
        format.html { render action: "edit" }
        format.json { render json: @group_instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /group_instructors/1
  # DELETE /group_instructors/1.json
  def destroy
    @group_instructor = GroupInstructor.find(params[:id])
    @group_instructor.destroy

    respond_to do |format|
      format.html { redirect_to group_instructors_url }
      format.json { head :no_content }
    end
  end

  private

  def load_form_data
    @group_schedules ||= GroupSchedule.all.select { |gs| gs.group.active? }
    @group_instructors ||= Member.instructors
    @semesters ||= Semester.order('start_on DESC').all
  end

end
