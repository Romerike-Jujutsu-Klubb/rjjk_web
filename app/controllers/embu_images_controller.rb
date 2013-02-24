class EmbuImagesController < ApplicationController
  # GET /embu_images
  # GET /embu_images.json
  def index
    @embu_images = EmbuImage.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @embu_images }
    end
  end

  # GET /embu_images/1
  # GET /embu_images/1.json
  def show
    @embu_image = EmbuImage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @embu_image }
    end
  end

  # GET /embu_images/new
  # GET /embu_images/new.json
  def new
    @embu_image = EmbuImage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @embu_image }
    end
  end

  # GET /embu_images/1/edit
  def edit
    @embu_image = EmbuImage.find(params[:id])
  end

  # POST /embu_images
  # POST /embu_images.json
  def create
    @embu_image = EmbuImage.new(params[:embu_image])

    respond_to do |format|
      if @embu_image.save
        format.html { redirect_to @embu_image, notice: 'Embu image was successfully created.' }
        format.json { render json: @embu_image, status: :created, location: @embu_image }
      else
        format.html { render action: "new" }
        format.json { render json: @embu_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /embu_images/1
  # PUT /embu_images/1.json
  def update
    @embu_image = EmbuImage.find(params[:id])

    respond_to do |format|
      if @embu_image.update_attributes(params[:embu_image])
        format.html { redirect_to @embu_image, notice: 'Embu image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @embu_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /embu_images/1
  # DELETE /embu_images/1.json
  def destroy
    @embu_image = EmbuImage.find(params[:id])
    @embu_image.destroy

    respond_to do |format|
      format.html { back_or_redirect_to embu_images_url }
      format.json { head :no_content }
    end
  end
end
