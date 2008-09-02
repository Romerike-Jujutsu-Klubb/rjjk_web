class Group < ActiveRecord::Base
  belongs_to :martial_art
  has_and_belongs_to_many :members, :conditions => 'left_on IS NULL'
end
