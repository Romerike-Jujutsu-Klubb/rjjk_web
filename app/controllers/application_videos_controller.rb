# frozen_string_literal: true

class ApplicationVideosController < ApplicationController
  before_action :set_application_video, only: %i[show edit update destroy]

  def index
    @application_videos = ApplicationVideo.all
  end

  def show; end

  def new
    @application_video = ApplicationVideo.new(params[:application_video])
    @application_video.build_image
    return unless (technique_application = @application_video.technique_application)

    @application_video.build_image.name ||=
        "#{technique_application.rank.name} #{technique_application.name}"
  end

  def edit; end

  def create
    @application_video ||= ApplicationVideo.new(application_video_params)
    if @application_video.save
      redirect_to @application_video, notice: 'Application video was successfully created.'
    else
      if @application_video.errors.details.dig(:'image.md5_checksum', 0, :error) == :taken
        @application_video.image = Image.find_by!(md5_checksum: @application_video.image.md5_checksum)
        return create
      end
      flash.alert = "Unable to save the video: #{@application_video.errors.full_messages.join(' ')}"
      render :new
    end
  end

  def update
    if @application_video.update(application_video_params)
      redirect_to @application_video, notice: 'Application video was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @application_video.destroy
    redirect_to application_videos_url, notice: 'Application video was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_application_video
    @application_video = ApplicationVideo.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def application_video_params
    params.require(:application_video).permit(:image_id, :technique_application_id,
        image_attributes: %i[cloudinary_upload_id file height md5_checksum name width])
  end
end
