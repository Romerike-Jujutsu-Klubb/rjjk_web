# frozen_string_literal: true
class SemestersController < ApplicationController
  before_filter :admin_required, except: [:index, :show]

  # GET /semesters
  # GET /semesters.json
  def index
    @semesters = Semester.order('start_on DESC').to_a
    @semester ||= Semester.where('CURRENT_DATE BETWEEN start_on AND end_on').first

    respond_to do |format|
      format.html { render action: :index }
      format.json { render json: @semesters }
    end
  end

  # GET /semesters/1
  # GET /semesters/1.json
  def show
    @semester = Semester.find(params[:id])
    index
  end

  # GET /semesters/new
  # GET /semesters/new.json
  def new
    @semester = Semester.new
    if (last_semester = Semester.order(:end_on).last)
      @semester.start_on = last_semester.end_on + 1
      @semester.end_on = last_semester.end_on + 1 + ((last_semester.end_on + 1).year * 12 + (last_semester.end_on + 1).month - last_semester.start_on.year * 12 - last_semester.start_on.month).months - 1
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @semester }
    end
  end

  # GET /semesters/1/edit
  def edit
    @semester = Semester.find(params[:id])
  end

  # POST /semesters
  # POST /semesters.json
  def create
    @semester = Semester.new(params[:semester])

    respond_to do |format|
      if @semester.save
        Group.where('school_breaks = ?', true).to_a.each do |g|
          @semester.group_semesters.create!(group_id: g.id) unless @semester.group_semesters.exists?(group_id: g.id)
        end

        format.html { redirect_to @semester, notice: 'Semester was successfully created.' }
        format.json { render json: @semester, status: :created, location: @semester }
      else
        format.html { render action: :new }
        format.json { render json: @semester.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /semesters/1
  # PUT /semesters/1.json
  def update
    @semester = Semester.find(params[:id])

    respond_to do |format|
      if @semester.update_attributes(params[:semester])
        format.html { redirect_to @semester, notice: 'Semester was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: :edit }
        format.json { render json: @semester.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /semesters/1
  # DELETE /semesters/1.json
  def destroy
    @semester = Semester.find(params[:id])
    @semester.destroy

    respond_to do |format|
      format.html { redirect_to semesters_url }
      format.json { head :no_content }
    end
  end
end
