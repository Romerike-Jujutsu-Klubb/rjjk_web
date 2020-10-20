# frozen_string_literal: true

class AttendanceFormController < ApplicationController
  include AttendanceFormDataLoader

  before_action :instructor_required

  def index
    @groups = Group.active(Date.current).order :from_age
    @my_groups = current_user.member.instruction_groups
    if params[:practice_id]
      @practice = Practice.find(params[:practice_id])
    else
      next_practice = @my_groups.map(&:next_practice).min_by(&:date)
      if next_practice&.date == Date.current
        @practice = next_practice
      elsif (last_practice = @my_groups.map(&:last_practice).max_by(&:date))&.date&.>=(Date.yesterday)
        @practice = last_practice
      else
        @practice = next_practice
      end
    end
  end
end
