# frozen_string_literal: true

class AttendanceFormController < ApplicationController
  include AttendanceFormDataLoader

  before_action :instructor_required

  def index
    @groups = Group.active(Date.current).order :from_age
    @my_groups = current_user.member.instruction_groups
    @my_groups += (@groups - @my_groups)
    if params[:practice_id]
      @practice = Practice.find(params[:practice_id])
    else
      next_practice = @my_groups.map(&:next_practice).min_by(&:date)
      if (next_practice&.date == Date.current) ||
            !(last_practice = @my_groups.map(&:last_practice).max_by(&:date))&.date&.>=(Date.yesterday)
        @practice = next_practice
      else
        @practice = last_practice
      end
    end
  end

  def show
    load_form_data(params[:year], params[:month], params[:group_id])
    render layout: 'print'
  end
end
