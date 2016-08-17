# frozen_string_literal: true
class EmbuImage < ActiveRecord::Base
  belongs_to :embu
  belongs_to :image

  validates_presence_of :embu_id, :image_id
  validates_uniqueness_of :image_id, scope: :embu_id
end
