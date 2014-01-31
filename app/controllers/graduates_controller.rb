class GraduatesController < ApplicationController
  before_filter :admin_required
  cache_sweeper :grade_history_image_sweeper, :only => [:create, :update, :destroy]

  def index
    if params[:id]
      @graduates = Graduate.all(:conditions => "member_id = #{params[:id]}", :order => 'rank_id')
    else
      @graduates = Graduate.all(:conditions => "member_id > 0", :order => 'member_id, rank_id DESC')
    end
  end

  def show_last_grade
    @members = Member.all
    @all_grades = @members.map { |m| m.current_grade }
    @grade_counts = {}
    @all_grades.each do |g|
      @grade_counts[g] ||= 0
      @grade_counts[g] += 1
    end
  end

  def annual_summary
    @year = params[:id]
    @graduates = Graduate.includes(:graduation).where("DATE_PART('YEAR', graduations.held_on) = ?", @year).order('rank_id').all
    @by_group = @graduates.group_by { |gr| gr.rank.group }
    @by_rank = @graduates.group_by { |gr| gr.rank }
  end

  def show
    @graduate = Graduate.find(params[:id])
  end

  def new
    @graduate = Graduate.new
  end

  def create
    @graduate = Graduate.new(params[:graduate])
    @graduate.rank_id ||= @graduate.member.next_rank(@graduate.graduation).id
    @graduate.paid_graduation ||= true
    @graduate.paid_belt ||= true
    @graduate.passed = @graduate.graduation.group.school_breaks? if @graduate.passed.nil?
    if @graduate.save
      flash[:notice] = 'Graduate was successfully created.'
      back_or_redirect_to :action => :index
    else
      render :action => 'new'
    end
  end

  def edit
    @graduate = Graduate.find(params[:id])
  end

  def update
    @graduate = Graduate.includes(:graduation, :member, :rank).find(params[:id])
    respond_to do |format|
      if @graduate.update_attributes(params[:graduate])
        format.html do
          flash[:notice] = 'Graduate was successfully updated.'
          redirect_to :action => 'show', :id => @graduate
        end
        format.json { head :no_content }
        format.js
      else
        format.html { render action: :edit }
        format.json { render json: @graduate.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    Graduate.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
