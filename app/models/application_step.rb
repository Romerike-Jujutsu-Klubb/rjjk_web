# frozen_string_literal: true

class ApplicationStep < ActiveRecord::Base
  acts_as_list scope: :technique_application_id

  belongs_to :technique_application

  default_scope { select((column_names - %w(content_data)).map { |c| "#{table_name}.#{c}" }) }
  scope :with_image, -> { select '*' }

  validates :position, :technique_application_id, presence: true
  validates :position, uniqueness: { scope: :technique_application_id }
end
