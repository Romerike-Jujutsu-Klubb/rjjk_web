# frozen_string_literal: true

module GoogleDriveContent
  def content_data_io
    logger.info "get google drive io: #{id} #{google_drive_reference}"
    unless google_drive_reference
      stored_content = move_to_google_drive!
      return stored_content if Rails.env.test?
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
      new_google_reference = GoogleDriveService.new
          .store_file(self.class.name.pluralize.underscore, id, loaded_content, content_type)
      update! google_drive_reference: new_google_reference, content_data: nil
    end
    loaded_content
  end
end
