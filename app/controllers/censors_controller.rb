# frozen_string_literal: true

class CensorsController < ApplicationController
  include GraduationAccess

  CENSOR_ACTIONS = %i[confirm decline show].freeze
  before_action :admin_required, except: [:create, :destroy, *CENSOR_ACTIONS]

  def index
    @censors = Censor.includes(:graduation).order('graduations.held_on DESC')
  end

  def show
    @censor = Censor.find(params[:id])
    return unless admin_or_censor_required(@censor.graduation)
  end

  def new
    @censor = Censor.new
  end

  def create
    if params[:censor][:member_id].blank?
      flash.notice = 'Velg en instruktør'
      back_or_redirect_to graduation_path(params[:censor][:graduation_id])
      return
    end
    @censor = Censor.where('graduation_id = ? AND member_id = ?',
        params[:censor][:graduation_id], params[:censor][:member_id]).first ||
        Censor.new(examiner: false)
    @censor.attributes = params[:censor]
    return unless admin_or_censor_required(@censor.graduation)
    if @censor.save
      flash[:notice] = "La til **#{@censor.member.name}** som #{@censor.role_name} på graderingen."
      back_or_redirect_to action: :index
    else
      render action: :new
    end
  end

  def edit
    @censor = Censor.find(params[:id])
  end

  def update
    @censor = Censor.find(params[:id])
    if @censor.update(params[:censor])
      flash[:notice] = 'Censor was successfully updated.'
      redirect_to action: :show, id: @censor
    else
      render action: :edit
    end
  end

  # From email link
  def confirm
    @censor = Censor.find(params[:id])
    return unless admin_or_censor_required(@censor.graduation)
    if @censor.update(confirmed_at: Time.zone.now, declined: false)
      flash[:notice] = 'Din deltakelse på gradering er bekreftet.'
      redirect_to edit_graduation_path(@censor.graduation, anchor: :censors_tab)
    else
      render action: :edit
    end
  end

  # From email link
  def decline
    @censor = Censor.find(params[:id])
    return unless admin_or_censor_required(@censor.graduation)
    if @censor.update(confirmed_at: Time.zone.now, declined: true)
      flash[:notice] = 'Ditt avslag på gradering er bekreftet.'
      redirect_to action: :show, id: @censor
    else
      render action: :edit
    end
  end

  def destroy
    censor = Censor.find(params[:id])
    censor.destroy!
    if request.xhr?
      render js: "$('#censor_#{censor.id}').remove()"
    else
      redirect_to action: :index
    end
  end
end
