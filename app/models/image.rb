class Image < ActiveRecord::Base
  def file=(file)
    return if file == ""
    self.name = file.original_filename if name.blank?
    self.content_data = file.read
    self.content_type = file.content_type
  end
  
  def format
    name.split('.').last
  end

  def content_data
    data = super
    if data =~ /^\\3(77|30)/
      logger.error "Image id=#{id} has invalid data."
      return eval("%Q{#{data}}")
    end
    data
  end

end
