# frozen_string_literal: true

module GoogleDriveContent
  def self.included(clas)
    clas.after_create_commit { |record| GoogleDriveUploadJob.perform_later(record.id) }
  end

  def content_data_io
    unless google_drive_reference
      stored_content = move_to_google_drive!
      return stored_content && StringIO.new(stored_content) if Rails.env.test?
    end
    google_drive_io
  end

  def google_drive_io
    logger.info "get google drive io: #{id} #{google_drive_reference}"
    GoogleDriveService.new.get_file_io(google_drive_reference)
  end

  def cloudinary_io
    Cloudinary::Downloader.download(cloudinary_identifier, type: 'upload', resource_type: video? ? 'video': 'image')
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
    logger.info "Store image in Google Drive: #{id}, #{name}"
    file = GoogleDriveService.new
        .store_file(self.class.name.pluralize.underscore, id, loaded_content, content_type)
    update! google_drive_reference: file.id, content_data: nil, md5_checksum: file.md5_checksum
  end

  private

  def load_content(no_caching: false)
    if content_loaded?
      content_data
    elsif google_drive_reference
      logger.info "Image found in Google Drive: #{id}, #{name}, #{google_drive_reference}"
      GoogleDriveService.new.get_file_content(google_drive_reference)
    elsif no_caching || Rails.env.test? # TODO(uwe): How can we test this?  WebMock?
      self.class.where(id: id).pick(:content_data)
    else
      move_to_google_drive!
    end
  end

  def content_loaded?
    attribute_present?(:content_data) && content_data.present?
  end
end
