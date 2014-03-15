class ApplicationStep < ActiveRecord::Base
  attr_accessible :decription, :image_content_data, :image_content_type,
      :image_filename, :position, :technique_application_id

  belongs_to :technique_application

  validates_presence_of :position, :technique_application_id
  validates_uniqueness_of :position, scope: :technique_application_id
end
