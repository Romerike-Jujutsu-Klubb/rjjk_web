# frozen_string_literal: true

class Signature < ApplicationRecord
  belongs_to :member

  validates :content_type, presence: true
  validates :image, presence: true
  validates :member_id, presence: true

  def file=(file)
    return if file.blank?
    self.name = file.original_filename
    self.image = file.read
    self.content_type = file.content_type
  end
end
