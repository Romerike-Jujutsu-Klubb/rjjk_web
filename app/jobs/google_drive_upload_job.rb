# frozen_string_literal: true

class GoogleDriveUploadJob < ApplicationJob
  queue_as :default

  def perform(image_id)
    image = Image.find(image_id)
    if image.google_drive_reference
      logger.error "Image already uploaded: #{image_id.inspect}"
      return
    end

    if image.content_data.nil?
      if image.cloudinary_identifier
        content_data = Cloudinary::Downloader.download(image.cloudinary_identifier)
        image.update! content_data: content_data
      else
        logger.error "Image content data is missing: #{image.id.inspect}"
        return
      end
    end

    image.move_to_google_drive!
  rescue => e
    logger.error "Job failed: #{e}"
    logger.error e.backtrace.join("\n")
  end
end
