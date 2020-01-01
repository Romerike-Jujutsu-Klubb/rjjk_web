# frozen_string_literal: true

class ApplicationStepsController < ApplicationController
  USER_ACTIONS = [:image].freeze
  before_action :technical_committy_required, except: USER_ACTIONS
  before_action :authenticate_user, only: USER_ACTIONS

  caches_page :image

  def index
    @application_steps = ApplicationStep.all
  end

  def show
    @application_step = ApplicationStep.find(params[:id])
  end

  def new
    @application_step ||= ApplicationStep.new(params[:application_step])
    load_form_data
    render :new
  end

  def edit
    @application_step ||= ApplicationStep.find(params[:id])
    load_form_data
    render :edit
  end

  def create
    @application_step = ApplicationStep.new(params[:application_step])
    if (existing_image = Image.find_by(md5_checksum: @application_step.image.md5_checksum))
      @application_step.image = existing_image
    end
    if @application_step.save
      redirect_to edit_technique_application_path(
          @application_step.application_image_sequence.technique_application
        ),
          notice: 'Application step was successfully created.'
    else
      new
    end
  end

  def update
    @application_step = ApplicationStep.find(params[:id])
    @application_step.attributes = params[:application_step]
    if (existing_image = Image.find_by(md5_checksum: @application_step.image.md5_checksum))
      @application_step.image = existing_image
    end
    if @application_step.save
      redirect_to edit_technique_application_path(
          @application_step.application_image_sequence.technique_application
        ),
          notice: 'Application step was successfully updated.'
    else
      edit
    end
  end

  def move_up
    application_step = ApplicationStep.find(params[:id])
    application_step.move_higher
    redirect_to edit_technique_application_path(application_step.technique_application)
  end

  def move_down
    application_step = ApplicationStep.find(params[:id])
    application_step.move_lower
    redirect_to edit_technique_application_path(application_step.technique_application)
  end

  def destroy
    application_step = ApplicationStep.find(params[:id])
    application_step.destroy
    redirect_to edit_technique_application_path(
        application_step.application_image_sequence.technique_application
      )
  end

  private

  def load_form_data
    @application_image_sequences = ApplicationImageSequence.all
  end
end
