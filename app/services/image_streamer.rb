# frozen_string_literal: true

# Cloudinary::Uploader.upload("sample.jpg", :crop => "limit", :tags => "samples", :width => 3000,
#     :height => 2000)

class ImageStreamer
  CHUNK_SIZE = 10 * 1024 * 1024

  def initialize(image_id)
    @image_id = image_id
  end

  def each
    image_length = Image.connection.execute(<<~SQL)[0]['length']
      SELECT LENGTH(content_data) as length
      FROM images WHERE id = #{@image_id}
    SQL
    (1..image_length).step(CHUNK_SIZE) do |i|
      data = Image.unscoped.select(<<~SQL).find(@image_id).chunk
        SUBSTRING(content_data FROM #{i} FOR #{[image_length - i + 1, CHUNK_SIZE].min}) as chunk
      SQL
      yield(data) if data
    end
  end
end
