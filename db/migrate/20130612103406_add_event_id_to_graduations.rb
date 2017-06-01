# frozen_string_literal: true

class AddEventIdToGraduations < ActiveRecord::Migration
  def change
    add_column :graduations, :event_id, :integer
    Graduation.all.each do |g|
      unless g.event
        g.create_event(name: g.name, start_at: g.start_at, end_at: g.end_at)
        g.save!
      end
    end
    change_column_null :graduations, :event_id, false
  end

  class Graduation < ApplicationRecord
    belongs_to :event
    belongs_to :group

    def start_at
      held_on.at(group_schedule.try(:start_at) || TimeOfDay.new(17, 45))
    end

    def end_at
      held_on.at(group_schedule.try(:end_at) || TimeOfDay.new(20, 30))
    end

    def name
      "Gradering #{group.name}"
    end

    def group_schedule
      group.group_schedules.find { |gs| gs.weekday == held_on.cwday }
    end
  end

  class Event < ApplicationRecord
  end

  class Group < ApplicationRecord
    has_many :group_schedules
  end

  class GroupSchedule < ApplicationRecord
  end
end
