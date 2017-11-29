# frozen_string_literal: true

class AddNotifiedMissingCensorsAtToGraduations < ActiveRecord::Migration[5.1]
  def change
    add_column :graduations, :notified_missing_censors_at, :datetime
  end
end
