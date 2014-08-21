class ApplicationStepsController < ApplicationController
  before_filter :technical_committy_required

  # FIXME(uwe):  Check caching
  caches_page :image
  # EMXIF

  def index
    @application_steps = ApplicationStep.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @application_steps }
    end
  end

  def show
    @application_step = ApplicationStep.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @application_step }
    end
  end

  def image
    step = ApplicationStep.
        select('id, image_filename, image_content_type, image_content_data').
        find(params[:id])
    begin
      imgs = Magick::ImageList.new
      imgs.from_blob step.image_content_data
    rescue java.lang.NullPointerException, java.lang.OutOfMemoryError
      redirect_to '/assets/pdficon_large.png'
      return
    end
    width = 320
    img_width = imgs.first.columns
    ratio = width.to_f / img_width
    imgs.each { |img| img.crop_resized!(width, img.rows * ratio) }
    send_data(imgs.to_blob, disposition: 'inline',
        type: step.image_content_type, filename: step.image_filename)
  end

  def new
    @application_step = ApplicationStep.new
    respond_to do |format|
      format.html # new.html.erb
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
        format.html { redirect_to @application_step, notice: 'Application step was successfully created.' }
        format.json { render json: @application_step, status: :created, location: @application_step }
      else
        format.html { render action: "new" }
        format.json { render json: @application_step.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @application_step = ApplicationStep.find(params[:id])
    respond_to do |format|
      if @application_step.update_attributes(params[:application_step])
        format.html { redirect_to @application_step, notice: 'Application step was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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
