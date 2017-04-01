# frozen_string_literal: true

class Signature < ActiveRecord::Base
  belongs_to :member

  def file=(file)
    return if file.blank?
    self.name = file.original_filename
    self.image = file.read
    self.content_type = file.content_type
  end
end
