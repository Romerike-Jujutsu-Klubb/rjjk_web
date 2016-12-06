# frozen_string_literal: true
class GraduatesController < ApplicationController
  before_action :admin_required

  # FIXME(uwe):  Fixe cache sweeping!
  # cache_sweeper :grade_history_image_sweeper, :only => [:create, :update, :destroy]

  def index
    @graduates =
        if params[:id]
          Graduate.where("member_id = #{params[:id]}").order(:rank_id).to_a
        else
          Graduate.where('member_id > 0').order('member_id, rank_id DESC').to_a
        end
  end

  def show_last_grade
    @members = Member.all
    @all_grades = @members.map(&:current_grade)
    @grade_counts = {}
    @all_grades.each do |g|
      @grade_counts[g] ||= 0
      @grade_counts[g] += 1
    end
  end

  def annual_summary
    @year = params[:id]
    @graduates = Graduate.includes(:graduation)
        .where("DATE_PART('YEAR', graduations.held_on) = ?", @year)
        .order('rank_id').to_a
    @by_group = @graduates.group_by { |gr| gr.rank.group }
    @by_rank = @graduates.group_by(&:rank)
  end

  def show
    @graduate = Graduate.find(params[:id])
  end

  def new
    @graduate ||= Graduate.new
    load_form_data
  end

  def create
    @graduate = Graduate.new(params[:graduate])
    @graduate.rank_id ||= @graduate.member.next_rank(@graduate.graduation).id
    @graduate.paid_graduation ||= true
    @graduate.paid_belt ||= true
    @graduate.passed = @graduate.graduation.group.school_breaks? if @graduate.passed.nil?
    if @graduate.save
      flash[:notice] = 'Graduate was successfully created.'
      back_or_redirect_to action: :index
    else
      new
      render action: :new
    end
  end

  def edit
    @graduate ||= Graduate.find(params[:id])
    load_form_data
  end

  def update
    @graduate = Graduate.includes(:graduation, :member, :rank).find(params[:id])
    respond_to do |format|
      if @graduate.update(params[:graduate])
        format.html do
          flash[:notice] = 'Graduate was successfully updated.'
          redirect_to action: :show, id: @graduate
        end
        format.json { head :no_content }
      else
        format.html do
          edit
          render action: :edit, layout: !request.xhr?
        end
        format.json { render json: @graduate.errors, status: :unprocessable_entity }
      end
      format.js { edit }
    end
  end

  def destroy
    @graduate = Graduate.find(params[:id])
    @graduate.destroy
    respond_to do |format|
      format.html { redirect_to action: :index }
      format.js { render js: %{$("#graduate_#{@graduate.id}").remove()} }
    end
  end

  private

  def load_form_data
    query = Rank.order(:position)
    if @graduate.graduation
      query = query.where(martial_art_id: @graduate.graduation.group.martial_art_id)
    end
    @ranks = query.to_a
  end
end
