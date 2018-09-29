# frozen_string_literal: true

class ImageDropzoneController < ApplicationController
  def upload
    image_params = params[:image]
    new_image = Image.new image_params
    md5_checksum = Digest::MD5.hexdigest(new_image.content_data)
    existing_image = Image.find_by(md5_checksum: md5_checksum)
    existing_image ||= Image.find_by(content_data: new_image.content_data)
    if existing_image
      image = existing_image
    else
      new_image.save!
      image = new_image
    end
    render json: { id: image.id, name: image.name, org_name: params[:image][:name] }
  end
end
