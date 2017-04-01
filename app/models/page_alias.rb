# frozen_string_literal: true

class PageAlias < ActiveRecord::Base
  validates :old_path, uniqueness: true
end
