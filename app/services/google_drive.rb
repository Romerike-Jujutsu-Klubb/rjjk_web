# frozen_string_literal: true

require 'google/apis/drive_v3'
Drive = Google::Apis::DriveV3 # Alias the module
ENV['GOOGLE_APPLICATION_CREDENTIALS'] = './rjjk-web-3268ab42fbde.json'

class GoogleDrive
  PHOTOS_DIR = "Photos#{"_#{Rails.env}" unless Rails.env.production?}"

  def initialize
    @drive = Drive::DriveService.new
    authorization = Google::Auth.get_application_default(['https://www.googleapis.com/auth/drive'])
    @drive.authorization = authorization
  end

  attr_reader :drive

  def create_photos_folder
    file_metadata = {
      name: PHOTOS_DIR,
      mime_type: 'application/vnd.google-apps.folder',
    }
    file = drive.create_file(file_metadata, fields: 'id')
    file.id
  end

  def store_photo(_upload_file)
    folder_id = find_photos_folder || create_photos_folder
    logger.info "Photos folder: #{folder_id}"

    drive.list_files(q: "'#{folder_id}' in parents", fields: 'files(id,name,web_view_link)')
        .files.each do |file|
      logger.info file
      logger.info "#{file.name} #{file.id&.length} #{file.id}"
    end

    # Upload a file
    metadata = Drive::File.new(title: 'My document', parents: [folder_id])
    metadata = drive.create_file(metadata, upload_source: 'card.txt', content_type: 'text/plain')

    metadata.id
  end

  # @param [String] spaces
  #   A comma-separated list of spaces to query within the corpus. Supported values
  #   are 'drive', 'appDataFolder' and 'photos'.
  def find_photos_folder
    folders = drive.fetch_all(items: :files) do |page_token|
      drive.list_files(q: "name='#{PHOTOS_DIR}'",
          spaces: 'drive',
          fields: 'nextPageToken, files(id, name)',
          page_token: page_token)
    end
    folder_id = nil
    folders.each do |folder|
      if folder_id.nil?
        folder_id = folder.id
      else
        # Delete duplicate folder
        logger.info 'Found duplicate Photos folder:'
        drive.list_files(q: "'#{folder.id}' in parents", fields: 'files(name,web_view_link)')
            .files.each do |file|
          logger.info file
          drive.update_file(id: file.id, remove_parents: folder.id, add_parents: folder_id)
        end
        drive.delete_file(folder.id)
      end
    end
    folder_id
  end

  def get_photo(id)
    drive.get_file(id, download_dest: 'tmp/myfile.txt')
  end
end
