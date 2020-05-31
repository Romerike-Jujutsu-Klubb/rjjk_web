# frozen_string_literal: true

class EmbuPartVideosController < ApplicationController
  before_action :authenticate_user
  before_action :set_embu_part_video, only: %i[show edit update destroy]

  def index
    @embu_part_videos = EmbuPartVideo.all
  end

  def show; end

  def new
    @embu_part_video = EmbuPartVideo.new
  end

  def edit; end

  def create
    @embu_part_video = EmbuPartVideo.new(embu_part_video_params)

    respond_to do |format|
      if @embu_part_video.save
        format.html { redirect_to @embu_part_video, notice: 'Embu part video was successfully created.' }
        format.json { render :show, status: :created, location: @embu_part_video }
      else
        format.html { render :new }
        format.json { render json: @embu_part_video.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @embu_part_video.update(embu_part_video_params)
        format.html { redirect_to @embu_part_video, notice: 'Embu part video was successfully updated.' }
        format.json { render :show, status: :ok, location: @embu_part_video }
      else
        format.html { render :edit }
        format.json { render json: @embu_part_video.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @embu_part_video.destroy
    respond_to do |format|
      format.html do
        redirect_to embu_part_videos_url, notice: 'Embu part video was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_embu_part_video
    @embu_part_video = EmbuPartVideo.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def embu_part_video_params
    params.require(:embu_part_video).permit(:embu_part_id, :image_id, :comment)
  end
end
