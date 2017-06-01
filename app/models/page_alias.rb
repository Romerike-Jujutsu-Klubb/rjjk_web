# frozen_string_literal: true

class PageAlias < ApplicationRecord
  validates :old_path, uniqueness: true
end
