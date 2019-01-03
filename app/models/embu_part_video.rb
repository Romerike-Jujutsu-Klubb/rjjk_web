# frozen_string_literal: true

class EmbuPartVideo < ApplicationRecord
  belongs_to :embu_part
  belongs_to :image
end
