# frozen_string_literal: true

class AddContentLengthToImages < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :cloudinary_transformed_at, :datetime
    add_column :images, :content_length, :integer
    images = Image.order(:id).to_a
    p(images.size) # rubocop: disable Rails/Output
    images.each.with_index do |i, j|
      p(images.size - j) if (images.size - j) % 10 == 0 # rubocop: disable Rails/Output
      s = i.content_data_io.size
      i.update! content_length: s
    rescue => e
      pp i # rubocop: disable Rails/Output
      pp e # rubocop: disable Rails/Output
      pp i.errors.full_messages # rubocop: disable Rails/Output
      pp i.errors[:md5_checksum] # rubocop: disable Rails/Output
      raise unless i.errors[:md5_checksum].any?

      p i # rubocop: disable Rails/Output
      puts 'md5 duplicate:' # rubocop: disable Rails/Output
      other = Image.where.not(id: i.id).find_by(md5_checksum: i.md5_checksum)
      p other # rubocop: disable Rails/Output
      other_md5 = Digest::MD5.hexdigest(other.content_data_io.to_s)
      if other.md5_checksum != other_md5
        puts "Update md5(#{other.id}): #{other.md5_checksum} => #{other_md5}" # rubocop: disable Rails/Output
        other.update! md5_checksum: other_md5
        retry
      end
      i.application_videos.destroy_all
      i.destroy!
      puts 'deleted' # rubocop: disable Rails/Output
    end
    change_column_null :images, :content_length, false
  end
end
