class PageAlias < ActiveRecord::Base
  validates_uniqueness_of :old_path
end
