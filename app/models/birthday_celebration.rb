class BirthdayCelebration < ActiveRecord::Base
  attr_accessible :held_on, :participants, :sensor1_id, :sensor2_id, :sensor3_id
  belongs_to :sensor1, :class_name => 'Member'
  belongs_to :sensor2, :class_name => 'Member'
  belongs_to :sensor3, :class_name => 'Member'
end
