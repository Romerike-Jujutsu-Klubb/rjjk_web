# frozen_string_literal: true
class EmbuImagesController < ApplicationController
  before_action :authenticate_user

  def index
    @embu_images = EmbuImage.all

    respond_to do |format|
      format.html
      format.json { render json: @embu_images }
    end
  end

  def show
    @embu_image = EmbuImage.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @embu_image }
    end
  end

  def new
    @embu_image ||= EmbuImage.new
    @embus = Embu.all
    @images = Image.order(:name).to_a

    respond_to do |format|
      format.html { render action: 'new' }
      format.json { render json: @embu_image }
    end
  end

  def edit
    @embu_image = EmbuImage.find(params[:id])
    @embus = Embu.all
    @images = Image.order(:name).to_a
  end

  def create
    @embu_image = EmbuImage.new(params[:embu_image])

    respond_to do |format|
      if @embu_image.save
        format.html { redirect_to @embu_image, notice: 'Embu image was successfully created.' }
        format.json { render json: @embu_image, status: :created, location: @embu_image }
      else
        format.html { new }
        format.json { render json: @embu_image.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @embu_image = EmbuImage.find(params[:id])

    respond_to do |format|
      if @embu_image.update_attributes(params[:embu_image])
        format.html { redirect_to @embu_image, notice: 'Embu image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @embu_image.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @embu_image = EmbuImage.find(params[:id])
    @embu_image.destroy

    respond_to do |format|
      format.html { back_or_redirect_to embu_images_url }
      format.json { head :no_content }
    end
  end
end
