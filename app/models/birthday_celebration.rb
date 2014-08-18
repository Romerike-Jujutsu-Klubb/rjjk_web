class BirthdayCelebration < ActiveRecord::Base
  belongs_to :sensor1, :class_name => 'Member'
  belongs_to :sensor2, :class_name => 'Member'
  belongs_to :sensor3, :class_name => 'Member'
end
