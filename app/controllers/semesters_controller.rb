# frozen_string_literal: true

class SemestersController < ApplicationController
  before_action :admin_required, except: %i[index show]

  def index
    @semesters = Semester.order('start_on DESC').to_a
    @semester ||= Semester.where('? BETWEEN start_on AND end_on', Date.current).first
    render action: :index
  end

  def show
    @semester = Semester.find(params[:id])
    index
  end

  def new
    @semester = Semester.new
    return unless (last_semester = Semester.order(:end_on).last)

    @semester.start_on = last_semester.end_on + 1
    @semester.end_on = (@semester.start_on >> 6) - 1
  end

  def edit
    @semester = Semester.find(params[:id])
  end

  def create
    @semester = Semester.new(params[:semester])
    if @semester.save
      Group.where('school_breaks = ?', true).to_a.each do |g|
        unless @semester.group_semesters.exists?(group_id: g.id)
          @semester.group_semesters.create!(group_id: g.id)
        end
      end
      redirect_to @semester, notice: 'Semester was successfully created.'
    else
      render action: :new
    end
  end

  def update
    @semester = Semester.find(params[:id])
    if @semester.update(params[:semester])
      redirect_to @semester, notice: 'Semester was successfully updated.'
    else
      render action: :edit
    end
  end

  def destroy
    @semester = Semester.find(params[:id])
    @semester.destroy
    redirect_to semesters_url
  end
end
