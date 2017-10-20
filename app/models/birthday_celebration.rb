# frozen_string_literal: true

class BirthdayCelebration < ApplicationRecord
  belongs_to :sensor1, class_name: 'Member', required: false
  belongs_to :sensor2, class_name: 'Member', required: false
  belongs_to :sensor3, class_name: 'Member', required: false

  validates :held_on, presence: true

  def sensors
    [sensor1, sensor2, sensor3].compact.uniq
  end
end
