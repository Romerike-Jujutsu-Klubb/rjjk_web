# frozen_string_literal: true

class AttendanceFormController < ApplicationController
  include AttendanceFormDataLoader

  before_action :instructor_required

  def index
    @groups = Group.active(Date.current).order :from_age
    @my_groups = current_user.member.instruction_groups
    if params[:practice_id]
      @practice = Practice.find(params[:practice_id])
    elsif (last_practice = @my_groups.map(&:last_practice).max_by(&:date)).date == Date.current
      @practice = last_practice
    elsif (next_practice = @my_groups.map(&:next_practice).min_by(&:date)).date == Date.current
      @practice = next_practice
    end
  end

  def show
    load_form_data(params[:year], params[:month], params[:group_id])
    render layout: 'print'
  end
end
