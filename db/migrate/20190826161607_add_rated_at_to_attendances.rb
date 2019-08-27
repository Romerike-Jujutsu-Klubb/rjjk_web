# frozen_string_literal: true

class AddRatedAtToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :rated_at, :datetime
  end
end
