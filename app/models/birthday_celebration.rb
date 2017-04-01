# frozen_string_literal: true

class BirthdayCelebration < ActiveRecord::Base
  belongs_to :sensor1, class_name: 'Member'
  belongs_to :sensor2, class_name: 'Member'
  belongs_to :sensor3, class_name: 'Member'

  validates :held_on, presence: true

  def sensors
    [sensor1, sensor2, sensor3].compact.uniq
  end
end
