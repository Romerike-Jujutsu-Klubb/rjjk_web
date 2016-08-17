# frozen_string_literal: true
class Image < ActiveRecord::Base
  CHUNK_SIZE = 10 * 1024 * 1024

  include UserSystem

  default_scope { select((column_names - %w(content_data)).map { |c| "images.#{c}" }) }
  scope :with_image, -> { select('*') }
  scope :published, -> { where(public: true, approved: true) }
  scope :images, -> { where("content_type LIKE 'image/%'") }

  belongs_to :user
  has_many :user_images, dependent: :destroy
  has_many :likers, -> { where("user_images.rel_type = 'LIKE'") },
      class_name: 'User', through: :user_images, source: :user

  before_create do
    self.user_id ||= current_user.try(:id)
  end

  validates_presence_of :name
  validates_uniqueness_of :content_data, on: :create

  after_create do |_|
    next unless @content_file
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
    self.content_data = 'Temporary'
    @content_file = file.path
    self.content_type = file.content_type
  end

  class Streamer
    def initialize(image)
      @image = image
    end

    def each
      image_length = Image.connection.execute("SELECT LENGTH(content_data) as length FROM images WHERE id = #{@image.id}")[0]['length']
      (1..image_length).step(CHUNK_SIZE) do |i|
        data = Image.connection.execute("SELECT SUBSTRING(content_data FROM #{i} FOR #{[image_length - i + 1, CHUNK_SIZE].min}) as chunk FROM images WHERE id = #{@image.id}")[0]['chunk']
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
    if width.nil? || height.nil?
      if attributes[:content_data].nil?
        self.content_data = self.class.select(:content_data).find(id).content_data
      end
      magick_image = Magick::Image.from_blob(content_data).first
      self.width = magick_image.columns
      self.height = magick_image.rows
      save!
    end
  end
end
