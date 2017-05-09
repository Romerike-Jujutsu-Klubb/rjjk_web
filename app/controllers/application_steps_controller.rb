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

  IMAGE_EXCEPTIONS =
      if defined?(JRUBY_VERSION)
        [java.lang.NullPointerException, java.lang.OutOfMemoryError]
      else
        [TypeError]
      end

  def image
    step = ApplicationStep
        .select('id, image_filename, image_content_type, image_content_data')
        .find(params[:id])
    if step.technique_application.rank > current_user.member.next_rank
      redirect_to login_path,
          notice: 'Du må ha høyere grad for å se på dette pensumet.'
      return
    end
    begin
      imgs = Magick::ImageList.new
      imgs.from_blob step.image_content_data
    rescue NoMethodError, *IMAGE_EXCEPTIONS
      redirect_to '/assets/pdficon_large.png'
      return
    end
    width = 320
    img_width = imgs.first.columns
    ratio = width.to_f / img_width
    imgs.each { |img| img.crop_resized!(width, img.rows * ratio) }
    send_data(imgs.to_blob, disposition: 'inline',
        type: step.image_content_type, filename: step.image_filename)
  ensure
    imgs&.each(&:destroy!)
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
      if @application_step.update_attributes(params[:application_step])
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
