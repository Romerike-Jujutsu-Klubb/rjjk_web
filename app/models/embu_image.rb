# frozen_string_literal: true
class EmbuImage < ActiveRecord::Base
  belongs_to :embu
  belongs_to :image

  validates :embu_id, :image_id, presence: true
  validates :image_id, uniqueness: { scope: :embu_id }
end
