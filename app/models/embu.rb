class Embu < ActiveRecord::Base
  extend UserSystem

  belongs_to :user
  belongs_to :rank
  has_many :embu_images
  has_many :images, through: :embu_images

  scope :mine, -> { where(user_id: current_user) }

  def image=(file)
    return if file == ''
    # content = file.read.force_encoding("ASCII-8BIT")
    # if existing_image = Image.find_by_content_data(content)
    #  if existing_embu_image = EmbuImage.find_by_embu_id_and_image_id(id, existing_image.id)
    #    logger.info "Embu image already exists"
    #    return existing_embu_image
    #  else
    #    logger.info "Image already exists.  Creating EmbuImage."
    #    return EmbuImage.create! :embu_id => id, :image_id => existing_image.id
    #  end
    # end
    # images.create :name => file.original_filename, :content_data => content, :content_type => file.content_type
    images.create :file => file
  end

end
