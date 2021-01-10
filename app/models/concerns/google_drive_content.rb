# frozen_string_literal: true

module GoogleDriveContent
  def self.included(clas)
    clas.after_create_commit { |record| GoogleDriveUploadJob.perform_later(record.id) }
  end

  def content_data_io
    GoogleDriveUploadJob.perform_later(id) unless google_drive_reference
    content_data_db_io || google_drive_io || cloudinary_io || self.class.where(id: id).pick(:content_data)
  end

  def content_data_db_io
    StringIO.new(content_data) if content_loaded?
  end

  def google_drive_file
    return unless google_drive_reference

    logger.info "get google drive file: #{id} #{google_drive_reference}"
    GoogleDriveService.new.get_file(google_drive_reference)
  end

  def google_drive_io
    return unless google_drive_reference

    logger.info "get google drive io: #{id} #{google_drive_reference}"
    GoogleDriveService.new.get_file_io(google_drive_reference)
  end

  def cloudinary_io
    return unless cloudinary_identifier

    Cloudinary::Downloader
        .download(cloudinary_identifier, type: 'upload', resource_type: video? ? 'video' : 'image')
  end

  def cloudinary_file
    return unless cloudinary_identifier

    Cloudinary::Api
        .resource(cloudinary_identifier, type: 'upload', resource_type: video? ? 'video' : 'image')
  end

  def move_to_google_drive!
    loaded_content, google_reference =
        self.class.where(id: id).pick(:content_data, :google_drive_reference)
    if loaded_content.blank?
      if google_reference
        self.google_drive_reference = google_reference
        return
      end
      GoogleDriveUploadJob.perform_now(id)
      return
    end
    upload_to_google_drive(loaded_content) unless Rails.env.test?
    loaded_content
  end

  def upload_to_google_drive(loaded_content)
    return if Rails.env.test?

    logger.info "Store image in Google Drive: #{id}, #{name}"
    file = GoogleDriveService.new
        .store_file(self.class.name.pluralize.underscore, id, loaded_content, content_type)
    update! google_drive_reference: file.id, content_data: nil, md5_checksum: file.md5_checksum
  end

  private

  def content_loaded?
    attribute_present?(:content_data) && content_data.present?
  end
end
