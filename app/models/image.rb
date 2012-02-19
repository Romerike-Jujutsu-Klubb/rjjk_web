class Image < ActiveRecord::Base
  def file=(file)
    return if file == ""
    self.name = file.original_filename if name.blank?
    file.binmode
    file.rewind
    self.content_data = file.read
    self.content_type = file.content_type
    logger.info ""
    logger.info "Stored image: #{content_data.size} bytes"
    logger.info ""
  end
  
  def format
    name.split('.').last
  end

  def content_data
    data = super
    return eval("%Q{#{data}}") if data =~ /^\\3(77|30)/
    data
  end

end

module ActionDispatch
  module Http
    class UploadedFile
      def binmode
        puts
        puts "Setting binmode"
        puts
        @tempfile.binmode
      end
    end
  end
end
