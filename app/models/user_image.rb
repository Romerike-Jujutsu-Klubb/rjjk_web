# frozen_string_literal: true

class UserImage < ApplicationRecord
  belongs_to :image
  belongs_to :user

  validates :image_id, uniqueness: { scope: %i[rel_type user_id] }
end
