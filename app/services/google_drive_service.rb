# frozen_string_literal: true

# require 'google_drive'
# require 'oauth2'
# require 'json'
# require 'pry'

# https://console.developers.google.com/apis/dashboard?project=api-project-983694128192&duration=PT1H
# https://console.developers.google.com/apis/library/drive.googleapis.com/?id=e44a1596-da14-427c-9b36-5eb6acce3775&project=api-project-983694128192&authuser=1
# https://console.developers.google.com/apis/library/drive.googleapis.com
#

class GoogleDriveService
  WEB_IMAGES_DIR = 'Web Images'

  attr_reader :session

  def initialize
    @session = GoogleDrive::Session.from_access_token(Rails.application.secrets.google_drive_refresh_token)
  end

  def get_file(id)
    @session.file_by_id(id).download_to_string
  end

  def get_file_io(id)
    logger.info 'download'
    @session.file_by_id(id).download_to_string
    # logger.info "download...OK"
    # Streamer.new(self, id)
  end

  def store_file(section, id, content, content_type)
    folder = find_or_create_folder(section)
    logger.info "Photos folder: #{folder}"
    file = folder
        .upload_from_string(content, "#{section}_#{id}", content_type: content_type, convert: false)
    file.id
  end

  private

  private def find_or_create_folder(section)
    environment_folder = find_or_create_environment_folder
    if (section_folder = environment_folder.file_by_title(section.to_s))
      logger.info "Google Drive section folder alrready exists: #{section}"
      return section_folder
    end
    logger.info "Create Google Drive section folder: #{section}"
    environment_folder.create_subcollection(section)
  end

  private def find_or_create_environment_folder
    top_folder = find_or_create_top_folder
    if (environment_folder = top_folder.file_by_title(Rails.env))
      logger.info "Google Drive environment folder alrready exists: #{Rails.env}"
      return environment_folder
    end
    logger.info "Create Google Drive environment folder: #{Rails.env}"
    top_folder.create_subcollection(Rails.env)
  end

  private def find_or_create_top_folder
    if (top_folder = @session.file_by_title(WEB_IMAGES_DIR))
      logger.info "Google Drive folder alrready exists: #{WEB_IMAGES_DIR}"
      return top_folder
    end
    logger.info "Create Google Drive folder: #{WEB_IMAGES_DIR}"
    @session.root_collection.create_subcollection(WEB_IMAGES_DIR)
  end

  class Streamer
    CHUNK_SIZE = 1 * 1024 * 1024

    def initialize(service, id)
      @service = service
      @file = @service.session.file_by_id(id)
      @chunk_no = 0
      logger.info "Streaming file: #{@file.size} bytes"
    end

    def each
      while @chunk_no * CHUNK_SIZE < @file.size
        @chunk_no += 1
        end_index = @chunk_no * CHUNK_SIZE - 1
        end_index = @file.size - 1 if end_index >= @file.size
        range = "bytes=#{(@chunk_no - 1) * CHUNK_SIZE}-#{end_index}"
        logger.info "Getting bytes: #{range}"
        data = @file.download_to_string # (options: {header: { Range: range }})
        yield(data) if data
      end
    end
  end
end
