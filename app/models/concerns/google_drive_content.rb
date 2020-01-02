# frozen_string_literal: true

module GoogleDriveContent
  def self.included(clas)
    clas.after_create { |record| GoogleDriveUploadJob.perform_later(record.id) }
  end

  def content_data_io
    logger.info "get google drive io: #{id} #{google_drive_reference}"
    unless google_drive_reference
      stored_content = move_to_google_drive!
      return stored_content && StringIO.new(stored_content) if Rails.env.test?
    end
    GoogleDriveService.new.get_file_io(google_drive_reference)
  end

  private

  def move_to_google_drive!
    logger.info "Store image in Google Drive: #{id}, #{name}"
    loaded_content, google_reference =
        self.class.where(id: id).pluck(:content_data, :google_drive_reference).first
    if loaded_content.nil? && google_reference
      self.google_drive_reference = google_reference
      return
    end
    unless Rails.env.test?
      file = GoogleDriveService.new
          .store_file(self.class.name.pluralize.underscore, id, loaded_content, content_type)
      update! google_drive_reference: file.id, content_data: nil, md5_checksum: file.md5_checksum
    end
    loaded_content
  end

  def load_content(no_caching: false)
    if content_loaded?
      content_data
    elsif google_drive_reference
      logger.info "Image found in Google Drive: #{id}, #{name}, #{google_drive_reference}"
      GoogleDriveService.new.get_file_content(google_drive_reference)
    elsif no_caching || Rails.env.test? # TODO(uwe): How can we test this?  WebMock?
      self.class.where(id: id).pluck(:content_data).first
    else
      move_to_google_drive!
    end
  end

  def content_loaded?
    attribute_present?(:content_data) && content_data.present?
  end
end
