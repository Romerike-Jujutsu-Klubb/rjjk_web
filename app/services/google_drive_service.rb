# frozen_string_literal: true

# https://console.developers.google.com/apis/dashboard?project=api-project-983694128192&duration=PT1H
# https://console.developers.google.com/apis/library/drive.googleapis.com/?id=e44a1596-da14-427c-9b36-5eb6acce3775&project=api-project-983694128192&authuser=1
# https://console.developers.google.com/apis/library/drive.googleapis.com

class GoogleDriveService
  WEB_IMAGES_DIR = 'Web Images'

  attr_reader :session

  # https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md#on-behalf-of-you-command-line-authorization
  # Run this to generate tmp/google_drive_client_secret.json
  #   PORT=3005 RAILS_ENV=production bin/rails s
  def initialize
    google_drive_client_config = Rails.application.credentials.google_drive_client_config
    config_file = 'tmp/google_drive_client_secret.json'
    unless File.exist?(config_file)
      File.write(config_file, JSON.dump(
          client_id: google_drive_client_config[:client_id],
          client_secret: google_drive_client_config[:client_secret],
          scope: %w[https://www.googleapis.com/auth/drive https://spreadsheets.google.com/feeds/],
          refresh_token: Rails.application.credentials.google_drive_refresh_token
        ))
    end
    @session = GoogleDrive::Session.from_config(config_file, google_drive_client_config.stringify_keys)
  end

  def get_file(id)
    @session.file_by_id(id)
  end

  def get_file_content(id)
    @session.file_by_id(id).download_to_string
  end

  def get_file_io(id)
    sio = StringIO.new
    sio.set_encoding(Encoding::BINARY)
    file = @session.file_by_id(id).download_to_io(sio)
    raise unless file == sio

    file.rewind
    file
  end

  def store_file(section, id, content, content_type)
    # FIXME(uwe): Try finding the file first
    folder = find_or_create_folder(section)
    folder.upload_from_string(content, "#{section}_#{id}", content_type: content_type, convert: false)
  end

  private

  def find_file_by_md5_checksum(section, md5_checksum)
    folder = find_or_create_folder(section)
    folder.files.find { |file| file.md5_checksum == md5_checksum }
  end

  def find_or_create_folder(section)
    environment_folder = find_or_create_environment_folder
    if (section_folder = environment_folder.file_by_title(section.to_s))
      return section_folder
    end

    logger.info "Create Google Drive section folder: #{section}"
    environment_folder.create_subcollection(section)
  end

  def find_or_create_environment_folder
    top_folder = find_or_create_top_folder
    if (environment_folder = top_folder.file_by_title(Rails.env))
      return environment_folder
    end

    logger.info "Create Google Drive environment folder: #{Rails.env}"
    top_folder.create_subcollection(Rails.env)
  end

  def find_or_create_top_folder
    if (top_folder = @session.file_by_title(WEB_IMAGES_DIR))
      return top_folder
    end

    logger.info "Create Google Drive folder: #{WEB_IMAGES_DIR}"
    @session.root_collection.create_subcollection(WEB_IMAGES_DIR)
  end
end
