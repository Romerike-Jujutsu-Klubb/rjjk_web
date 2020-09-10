# frozen_string_literal: true

class CloudinaryUploadJob < ApplicationJob
  queue_as :default

  def perform(image_id)
    image = Image.find(image_id)
    if image.cloudinary_identifier
      logger.error "Image already uploaded: #{image_id.inspect}"
    else
      result = Cloudinary::Uploader.upload_large(
          image.content_data_io,
          resource_type: image.video? ? 'video' : 'image',
          public_id: "#{Rails.env}/images/#{image.id}"
        )
      logger.info "Cloudinary upload result: #{result.inspect}"
      image.cloudinary_identifier = result['public_id']
      image.width ||= result['width']
      image.height ||= result['height']

      image.save!
    end
    CloudinaryTransformJob.perform_later(image.id)
  rescue => e
    logger.error "Job failed: #{e}"
    logger.error e.backtrace.join("\n")
  end
end
