# frozen_string_literal: true

class Embu < ApplicationRecord
  extend UserSystem

  belongs_to :user
  belongs_to :rank
  has_many :embu_images
  has_many :images, through: :embu_images

  scope :mine, -> { where(user_id: current_user.id) }

  def image=(file)
    return if file == ''
    images.create file: file
  end
end
