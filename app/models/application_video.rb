# frozen_string_literal: true

class ApplicationVideo < ApplicationRecord
  belongs_to :technique_application
  belongs_to :image

  accepts_nested_attributes_for :image

  validates :image_id, uniqueness: { scope: :technique_application_id }
end
