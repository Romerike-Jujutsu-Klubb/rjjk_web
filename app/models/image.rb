# frozen_string_literal: true

class Image < ApplicationRecord
  include GoogleDriveContent
  include UserSystem

  scope :without_image, -> { select((column_names - %w[content_data]).map { |c| "images.#{c}" }) }
  scope :with_image, -> { select('*') }
  scope :published, -> { where(public: true, approved: true) }
  scope :images, -> { where("content_type LIKE 'image/%'") }

  belongs_to :user, -> { with_deleted }, inverse_of: :images

  has_one :application_step, dependent: :nullify
  has_one :member_image, dependent: :destroy
  has_one :user_like,
      -> do
        where("user_images.rel_type = 'LIKE'").where('user_images.user_id = ?', Thread.current[:user].id)
      end,
      class_name: 'UserImage',
      inverse_of: :image

  has_many :user_images, dependent: :destroy

  has_many :likers, -> { where("user_images.rel_type = 'LIKE'") },
      class_name: 'User', through: :user_images, source: :user

  before_validation { self.user_id ||= current_user&.id }

  validates :name, presence: true
  validate do
    errors.add :file, 'må velges.' if content_type.blank?

    if attribute_present?(:content_data) && content_data.present? &&
          self.class.where(content_data: content_data).where.not(id: id).exists?
      errors.add :file, 'Dette bildet er allerede lastet opp.'
    end

    errors.add :public, 'kan bare endres av en administrator' if public_changed? && !admin?
    errors.add :approved, 'kan bare endres av en administrator' if approved_changed? && !admin?
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

  def format
    MIME::Types[content_type].first.extensions.first
  end

  def video?
    content_type =~ %r{^video/}
  end

  def aspect_ratio
    update_dimensions! unless video?
    return (width.to_f / height) if width && height

    320 / 240
  end

  def width_max(max_width)
    update_dimensions!
    [width, max_width].min.to_i
  end

  def height_at(max_width)
    return max_width * 240 / 320 if video?

    update_dimensions!
    ratio = max_width.to_f / width
    max_height = height * ratio
    [height, max_height].min.to_i
  end

  def update_dimensions!
    return unless width.nil? || height.nil?

    magick_image = Magick::Image.from_blob(load_content(no_caching: true)).first
    self.width = magick_image.columns
    self.height = magick_image.rows
    save!
  end

  def load_content(no_caching: false)
    if google_drive_reference
      image_content = GoogleDriveService.new.get_file(google_drive_reference)
      logger.info "Image found in Google Drive: #{id}, #{name}, #{google_drive_reference}"
    elsif no_caching || Rails.env.test? # TODO(uwe): How can we test this?  WebMock?
      image_content = self.class.where(id: id).pluck(:content_data).first
    else
      image_content = move_to_google_drive!
    end
    image_content
  end
end
