# frozen_string_literal: true

class CardKey < ApplicationRecord
  belongs_to :user, optional: true

  validates :label, presence: true
end
