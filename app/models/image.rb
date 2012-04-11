class Image < ActiveRecord::Base
  include UserSystem

  belongs_to :user
  has_many :user_images
  has_many :likers, :class_name => 'User', :through => :user_images, :conditions => "user_images.rel_type = 'LIKE'", :source => :user

  before_create do
    self.user ||= current_user
  end

  validates_uniqueness_of :content_data, :on => :create

  after_create do |i|
    next unless @content_file
    conn = self.class.connection.raw_connection.connection
    is = java.io.FileInputStream.new(java.io.File.new(@content_file))
    st = conn.prepareStatement("UPDATE images SET content_data = ? WHERE id = ?")
    st.java_send(:setBinaryStream, [Java::int, java.io.InputStream, Java::int], 1, is, is.available)
    st.setInt(2, id)
    st.executeUpdate
    st.close
    @content_file = nil
  end

  def file=(file)
    return if file == ""
    self.name = file.original_filename if name.blank?
    self.content_data = 'Temporary'
    @content_file = file.path
    self.content_type = file.content_type
  end

  if Rails.env == 'development'
    def content_data
      data = super
      if data =~ /^\\3(77|30)/
        logger.error "Image id=#{id} has invalid data."
        return eval("%Q{#{data}}")
      end
      data
    end
  end

  class Streamer
    def initialize(image)
      @image = image
    end
    def each(&block)
      chunk_size = 10 * 1024 * 1024
      image_length = Image.connection.execute("SELECT LENGTH(content_data) as length FROM images WHERE id = #{@image.id}")[0]['length']
      (1..image_length).step(chunk_size) do |i|
        data = Image.connection.execute("SELECT SUBSTRING(content_data FROM #{i} FOR #{[image_length - i, chunk_size].min}) as chunk FROM images WHERE id = #{@image.id}")[0]['chunk']
        block.call(data) if data
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
    content_type =~ /^video\//
  end

end
