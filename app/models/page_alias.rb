# frozen_string_literal: true
class PageAlias < ActiveRecord::Base
  validates_uniqueness_of :old_path
end
