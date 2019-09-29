# frozen_string_literal: true

class ApplicationVideo < ApplicationRecord
  belongs_to :technique_application
  belongs_to :image

  accepts_nested_attributes_for :image
end
