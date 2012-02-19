class Image < ActiveRecord::Base
  def file=(file)
    return if file == ""
    self.name = file.original_filename if name.blank?
    logger.info file.tempfile.to_s
    logger.info `ls -l #{file.tempfile}`
    file.tempfile.binmode
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
