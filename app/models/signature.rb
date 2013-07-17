class Signature < ActiveRecord::Base
  attr_accessible :content_type, :file, :image, :member_id, :name
  belongs_to :member

  def file=(file)
    return if file.blank?
    self.name = file.original_filename
    self.image = file.read
    self.content_type = file.content_type
  end

end
