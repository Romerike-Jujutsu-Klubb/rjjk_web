# frozen_string_literal: true

class Image < ApplicationRecord
  CHUNK_SIZE = 10 * 1024 * 1024

  include UserSystem

  scope :without_image, -> { select((column_names - %w[content_data]).map { |c| "images.#{c}" }) }
  scope :with_image, -> { select('*') }
  scope :published, -> { where(public: true, approved: true) }
  scope :images, -> { where("content_type LIKE 'image/%'") }

  belongs_to :user
  has_many :user_images, dependent: :destroy
  has_many :likers, -> { where("user_images.rel_type = 'LIKE'") },
      class_name: 'User', through: :user_images, source: :user

  before_create { self.user_id ||= current_user&.id }

  validates :name, presence: true
  validate do
    errors.add :file, 'må velges.' if content_type.blank?

    if attribute_present?(:content_data) && content_data.present? &&
          self.class.where(content_data: content_data).where.not(id: id).exists?
      errors.add :file, 'Dette bildet er allerede lastet opp.'
    end

    if public_changed? && !admin?
      errors.add :public, 'kan bare endres av en administrator'
    end
    if approved_changed? && !admin?
      errors.add :approved, 'kan bare endres av en administrator'
    end
  end

  after_create do |_|
    next unless @content_file
    raise "Unexpected @content_file: #{@content_file}" unless RUBY_ENGINE == 'jruby'
    conn = self.class.connection.raw_connection.connection
    is = java.io.FileInputStream.new(java.io.File.new(@content_file))
    st = conn.prepareStatement('UPDATE images SET content_data = ? WHERE id = ?')
    st.java_send(:setBinaryStream, [Java::int, java.io.InputStream, Java::int], 1, is, is.available)
    st.setInt(2, id)
    st.executeUpdate
    st.close
    @content_file = nil
  end

  def file=(file)
    return if file == ''
    self.name = file.original_filename if name.blank?
    if RUBY_ENGINE == 'jruby'
      # Allow huge file uploads
      self.content_data = 'Temporary'
      @content_file = file.path
    else
      self.content_data = file.read
    end
    self.content_type = file.content_type if file.content_type.present?
  end

  class Streamer
    def initialize(image)
      @image = image
    end

    def each
      image_length = Image.connection.execute(<<~SQL)[0]['length']
        SELECT LENGTH(content_data) as length
        FROM images WHERE id = #{@image.id}
      SQL
      (1..image_length).step(CHUNK_SIZE) do |i|
        data = Image.unscoped.select(<<~SQL).find(@image.id).chunk
          SUBSTRING(
            content_data FROM #{i} FOR #{[image_length - i + 1, CHUNK_SIZE].min}
          ) as chunk
        SQL
        yield(data) if data
      end
    end
  end

  def content_data_io
    Streamer.new(self)
  end

  def format
    name.split('.').last
  end

  def video?
    content_type =~ %r{^video/}
  end

  def width_max(max_width)
    update_dimensions!
    [width, max_width].min.to_i
  end

  def height_at(max_width)
    update_dimensions!
    ratio = max_width.to_f / width
    max_height = height * ratio
    [height, max_height].min.to_i
  end

  def update_dimensions!
    return unless width.nil? || height.nil?
    if attributes[:content_data].nil?
      self.content_data = self.class.select(:content_data).find(id).content_data
    end
    magick_image = Magick::Image.from_blob(content_data).first
    self.width = magick_image.columns
    self.height = magick_image.rows
    save!
  end
end
