# frozen_string_literal: true

class AddTimestampsToGraduations < ActiveRecord::Migration
  def change
    add_column :censors, :lock_reminded_at, :datetime
    add_column :censors, :locked_at, :datetime
    add_column :censors, :declined, :boolean
    add_column :graduations, :shopping_list_sent_at, :datetime
    add_column :graduates, :invitation_sent_at, :datetime
    add_column :graduates, :confirmed_at, :datetime
    add_column :graduates, :declined, :boolean
    now = Time.zone.now
    Censor.joins(:graduation).where('graduations.held_on < ?', now)
        .update_all(requested_at: now, confirmed_at: now, lock_reminded_at: now,
            locked_at: now)
    Graduation.update_all(shopping_list_sent_at: now)
    Graduate.joins(:graduation).where('graduations.held_on < ?', now)
        .update_all(invitation_sent_at: now, confirmed_at: now)
  end

  class Censor < ApplicationRecord
    belongs_to :graduation
  end
  Graduation = Class.new ApplicationRecord
  class Graduate < ApplicationRecord
    belongs_to :graduation
  end
end
