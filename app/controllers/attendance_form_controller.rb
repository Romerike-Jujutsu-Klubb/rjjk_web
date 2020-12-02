# frozen_string_literal: true

class AttendanceFormController < ApplicationController
  include AttendanceFormDataLoader

  before_action :instructor_required

  def index
    @groups = Group.active(Date.current).includes(:group_schedules).order(:from_age).to_a
        .select { |g| g.group_schedules.any? }
    @my_groups = current_user.member.instruction_groups
    @groups = @my_groups | @groups # Display my groups first
    load_practice(*@my_groups)
  end

  def group
    group = Group.find(params[:id])
    load_practice(group)
    render :group, locals: { group: group }, layout: false
  end

  def show
    load_form_data(params[:year].to_i, params[:month].to_i, params[:group_id])
  end

  private

  def load_practice(*groups)
    if params[:practice_id]
      @practice = Practice.find(params[:practice_id])
    else
      next_practice = groups.map(&:next_practice).min_by(&:date)
      @practice = if (next_practice&.date == Date.current) ||
            !(last_practice = groups.map(&:last_practice).max_by(&:date))&.date&.>=(Date.yesterday)
                    next_practice
                  else
                    last_practice
                  end
    end
  end
end
