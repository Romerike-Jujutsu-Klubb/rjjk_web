# frozen_string_literal: true

class UserImage < ApplicationRecord
  belongs_to :user
  belongs_to :image

  validates :image_id, uniqueness: { scope: %i(rel_type user_id) }
end
