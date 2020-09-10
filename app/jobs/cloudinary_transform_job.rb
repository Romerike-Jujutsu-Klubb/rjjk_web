# frozen_string_literal: true

class CloudinaryTransformJob < ApplicationJob
  queue_as :default

  def perform(image_id)
    image = Image.find(image_id)
    unless image.cloudinary_identifier
      logger.error "Image has not been uploaded to Cloudinary: #{image_id.inspect}"
      return
    end
    if !image.video? || image.content_length <= 40.megabytes
      logger.error "Image does not need transformation: #{image_id.inspect}"
      return
    end
    if image.cloudinary_transformed_at
      logger.error "Image already transformed: #{image_id.inspect}"
      return
    end

    cl_id = image.cloudinary_identifier
    cl_id = cl_id.sub(%r{^v\d+/}, '')

    result = Cloudinary::Uploader.explicit(cl_id,
        type: 'upload',
        resource_type: :video,
        async: true,
        eager_async: true,
        eager: [
          { format: :webm },
          { format: :webm, width: 88, height: 88, crop: :fit },
        ])
    logger.info "Cloudinary explicit result: #{result}"
    image.update! cloudinary_transformed_at: Time.current if result['status'] == 'pending'
  rescue => e
    logger.error "Job failed: #{e}"
    logger.error e.backtrace.join("\n")
  end
end
