class PageAlias < ActiveRecord::Base
  attr_accessible :new_path, :old_path

  validates_uniqueness_of :old_path
end
