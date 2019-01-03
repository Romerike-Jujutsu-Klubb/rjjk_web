# frozen_string_literal: true

class EmbuPart < ApplicationRecord
  belongs_to :embu

  has_many :embu_part_videos, dependent: :destroy
end
