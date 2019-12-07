# frozen_string_literal: true

class CardKey < ApplicationRecord
  belongs_to :user, optional: true

  before_validation do
    self.label = nil if label.blank?
  end

  validates :label, presence: true, allow_blank: true
end
