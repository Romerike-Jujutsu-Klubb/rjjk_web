class ApplicationStep < ActiveRecord::Base
  acts_as_list scope: :technique_application_id

  belongs_to :technique_application

  default_scope {select((column_names - %w(content_data)).map{|c| "#{table_name}.#{c}"})}
  scope :with_image, :select =>	'*'

  validates_presence_of :position, :technique_application_id
  validates_uniqueness_of :position, scope: :technique_application_id
end
