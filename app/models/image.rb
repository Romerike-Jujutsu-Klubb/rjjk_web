class Image < ActiveRecord::Base
  def file=(file)
    return if file == ""
    self.name = file.original_filename
    self.content_data = file.read
    self.content_type = file.content_type
  end
  
  def format
    name.split('.').last
  end
  
end
