class Group < ActiveRecord::Base
  belongs_to :martial_art
  has_and_belongs_to_many :members
  has_many :group_schedules
  
  def full_name
    "#{martial_art.name} #{name}"
  end
  
  def contains_age(age)
    age >= from_age && age <= to_age
  end
  
end
