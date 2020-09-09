# frozen_string_literal: true

class GoogleDriveUploadJob < ApplicationJob
  queue_as :default

  def perform(image_id)
    image = Image.find(image_id)
    if image.google_drive_reference
      logger.error "Image already uploaded: #{image_id.inspect}"
      return
    end

    if image.content_data.blank?
      if image.cloudinary_identifier
        content_data = image.cloudinary_io
        if content_data.present?
          image.update! content_data: content_data
          # if image.content_length != content_data.size
          #   logger.error "Image content length mismatch: #{image.content_length} => #{content_data.size}"
          #   image.update! content_length: content_data.size
          # end
        else
          logger.error "Cloudinary content data is missing: #{content_data.inspect}"
          return
        end
      else
        logger.error "Image content data is missing: #{image.id.inspect}"
        return
      end
    end

    image.upload_to_google_drive(image.content_data)
  rescue => e
    logger.error "Job failed: #{e}"
    logger.error e.backtrace.join("\n")
    ExceptionNotifier.notify_exception(e)
  end
end
