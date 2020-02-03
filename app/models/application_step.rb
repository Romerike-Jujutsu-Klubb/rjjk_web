# frozen_string_literal: true

class ApplicationStep < ApplicationRecord
  acts_as_list scope: :application_image_sequence_id

  belongs_to :application_image_sequence
  belongs_to :image, optional: true

  has_one :technique_application, through: :application_image_sequence

  scope :without_image, -> { select((column_names - %w[content_data]).map { |c| "#{table_name}.#{c}" }) }

  accepts_nested_attributes_for :image

  validates :application_image_sequence_id, presence: true
end
