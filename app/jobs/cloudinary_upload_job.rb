# frozen_string_literal: true

class CloudinaryUploadJob < ApplicationJob
  queue_as :default

  def perform(image_id)
    image = Image.find(image_id)
    if image.cloudinary_identifier
      logger.error "Image already uploaded: #{image_id.inspect}"
      return
    end
    result = Cloudinary::Uploader.upload_large(
        image.content_data_io,
        resource_type: image.video? ? 'video' : 'image',
        public_id: "#{Rails.env}/images/#{image.id}"
      )
    logger.info "Cloudinary upload result: #{result}"
    image.cloudinary_identifier = "v#{result['version']}/#{result['public_id']}"
    image.width ||= result['width']
    image.height ||= result['height']

    image.save!
  rescue => e
    logger.error "Job failed: #{e}"
    logger.error e.backtrace.join("\n")
  end
end
