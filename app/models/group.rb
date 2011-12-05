class Group < ActiveRecord::Base
  belongs_to :martial_art
  has_and_belongs_to_many :members, :conditions => 'left_on IS NULL OR left_on > DATE(CURRENT_TIMESTAMP)'
  has_many :group_schedules
  has_many :ranks, :order => :position
  
  def full_name
    "#{martial_art.name} #{name}"
  end
  
  def contains_age(age)
    return false if age.nil?
    age >= from_age && age <= to_age
  end
  
end
