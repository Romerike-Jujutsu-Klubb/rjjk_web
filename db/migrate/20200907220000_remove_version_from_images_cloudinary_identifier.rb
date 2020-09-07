# frozen_string_literal: true

class RemoveVersionFromImagesCloudinaryIdentifier < ActiveRecord::Migration[6.0]
  def change
    images = Image.order(:id).to_a
    p(images.size) # rubocop: disable Rails/Output
    images.each.with_index do |i, j|
      p(images.size - j) if (images.size - j) % 10 == 0 # rubocop: disable Rails/Output
      if i.cloudinary_identifier
        i.update! cloudinary_identifier: i.cloudinary_identifier.sub(%r{^v\d+/}, '')
      end
    end
  end

  class Image < ActiveRecord::Base; end
end
