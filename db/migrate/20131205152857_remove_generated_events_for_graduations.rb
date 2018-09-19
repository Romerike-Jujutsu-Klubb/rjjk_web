# frozen_string_literal: true

class RemoveGeneratedEventsForGraduations < ActiveRecord::Migration[4.2]
  def up
    Graduation.all.each do |g|
      g.event.destroy
    end
    remove_column :graduations, :event_id
  end

  def down
    remove_column :graduations, :event_id, null: false
  end

  class Graduation < ApplicationRecord
    belongs_to :event
  end

  class Event < ApplicationRecord
  end
end
