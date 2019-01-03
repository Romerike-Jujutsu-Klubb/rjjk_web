# frozen_string_literal: true

class Image < ApplicationRecord
  include GoogleDriveContent

  scope :without_image, -> { select((column_names - %w[content_data]).map { |c| "images.#{c}" }) }
  scope :with_image, -> { select('*') }
  scope :published, -> { where(public: true, approved: true) }
  scope :images, -> { where("content_type LIKE 'image/%'") }

  belongs_to :user, -> { with_deleted }, inverse_of: :images

  has_one :member_image, dependent: :destroy
  has_one :user_like, -> do
    where("user_images.rel_type = 'LIKE'").where('user_images.user_id = ?', Thread.current[:user].id)
  end, class_name: 'UserImage', inverse_of: :image

  has_many :application_steps, dependent: :nullify
  has_many :embu_part_videos, dependent: :destroy
  has_many :user_images, dependent: :destroy

  has_many :likers, -> { where("user_images.rel_type = 'LIKE'") },
      class_name: 'User', through: :user_images, source: :user

  before_validation do
    self.user_id ||= current_user&.id
    self.md5_checksum = Digest::MD5.hexdigest(content_data) if md5_checksum.blank? && content_loaded?
  end

  validates :md5_checksum, presence: true, uniqueness: true
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

  def file=(file)
    return if file == ''

    self.name = file.original_filename if name.blank?
    self.content_data = file.read
    self.content_type = file.content_type if file.content_type.present?
  end

  def format
    extensions = MIME::Types[content_type].first&.extensions
    extensions&.select { |e| e.size <= 3 }&.first || extensions&.first || name.split('.').last
  end

  def video?
    content_type =~ %r{^video/}
  end

  def image?
    content_type =~ %r{^image/}
  end

  def aspect_ratio
    update_dimensions!
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
    return max_width * 240 / 320 unless width && height

    ratio = max_width.to_f / width
    max_height = height * ratio
    [height, max_height].min.to_i
  end

  def update_dimensions!
    return if (width && height) || !image?

    content = load_content(no_caching: true)
    magick_image = Magick::Image.from_blob(content).first
    self.width = magick_image.columns
    self.height = magick_image.rows

    save!
  rescue => e
    logger.error e
    logger.error e.backtrace.join("\n")
  end
end
