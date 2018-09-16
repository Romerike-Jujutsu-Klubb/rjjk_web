# frozen_string_literal: true

class ApplicationStepsController < ApplicationController
  USER_ACTIONS = [:image].freeze
  before_action :technical_committy_required, except: USER_ACTIONS
  before_action :authenticate_user, only: USER_ACTIONS

  caches_page :image

  def index
    @application_steps = ApplicationStep.all
    respond_to do |format|
      format.html
      format.json { render json: @application_steps }
    end
  end

  def show
    @application_step = ApplicationStep.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @application_step }
    end
  end

  def new
    @application_step = ApplicationStep.new
    respond_to do |format|
      format.html
      format.json { render json: @application_step }
    end
  end

  def edit
    @application_step = ApplicationStep.find(params[:id])
  end

  def create
    @application_step = ApplicationStep.new(params[:application_step])
    respond_to do |format|
      if @application_step.save
        format.html do
          redirect_to @application_step, notice: 'Application step was successfully created.'
        end
        format.json do
          render json: @application_step, status: :created, location: @application_step
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @application_step.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @application_step = ApplicationStep.find(params[:id])
    respond_to do |format|
      if @application_step.update(params[:application_step])
        format.html do
          redirect_to @application_step, notice: 'Application step was successfully updated.'
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @application_step.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @application_step = ApplicationStep.find(params[:id])
    @application_step.destroy
    respond_to do |format|
      format.html { redirect_to application_steps_url }
      format.json { head :no_content }
    end
  end
end
