class Embu < ActiveRecord::Base
  belongs_to :user
  belongs_to :rank
  has_many :embu_images
  has_many :images, :through => :embu_images

  def image=(file)
    return if file == ""
    images.create :name => file.original_filename, :content_data => file.read, :content_type => file.content_type
  end

end
