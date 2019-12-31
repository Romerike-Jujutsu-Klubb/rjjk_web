# frozen_string_literal: true

class ApplicationStep < ApplicationRecord
  acts_as_list scope: :technique_application_id

  belongs_to :image
  belongs_to :technique_application

  scope :without_image, -> { select((column_names - %w[content_data]).map { |c| "#{table_name}.#{c}" }) }

  accepts_nested_attributes_for :image

  validates :technique_application_id, presence: true
end
