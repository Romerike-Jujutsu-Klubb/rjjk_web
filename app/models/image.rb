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
    return eval("\"#{data}\"") if data =~ /^\\377\\330\\377/
    data
  end

end
