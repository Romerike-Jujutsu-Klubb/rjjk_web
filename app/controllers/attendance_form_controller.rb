# frozen_string_literal: true

class AttendanceFormController < ApplicationController
  include AttendanceFormDataLoader

  before_action :instructor_required

  def index
    @groups = Group.active(Date.current).order :from_age
  end

  def show
    load_form_data(params[:year], params[:month], params[:group_id])
    render layout: 'print'
  end
end
