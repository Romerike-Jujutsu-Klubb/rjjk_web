class GroupSemestersController < ApplicationController
  before_filter :admin_required

  def index
    @group_semesters = GroupSemester.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @group_semesters }
    end
  end

  def show
    @group_semester = GroupSemester.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group_semester }
    end
  end

  def new
    @group_semester = GroupSemester.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group_semester }
    end
  end

  def edit
    @group_semester = GroupSemester.find(params[:id])
  end

  def create
    @group_semester = GroupSemester.new(params[:group_semester])

    respond_to do |format|
      if @group_semester.save
        format.html { redirect_to @group_semester, notice: 'Group semester was successfully created.' }
        format.json { render json: @group_semester, status: :created, location: @group_semester }
      else
        format.html { render action: 'new' }
        format.json { render json: @group_semester.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @group_semester = GroupSemester.find(params[:id])

    respond_to do |format|
      if @group_semester.update_attributes(params[:group_semester])
        format.html { redirect_to @group_semester, notice: 'Group semester was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @group_semester.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @group_semester = GroupSemester.find(params[:id])
    @group_semester.destroy

    respond_to do |format|
      format.html { redirect_to group_semesters_url }
      format.json { head :no_content }
    end
  end
end
