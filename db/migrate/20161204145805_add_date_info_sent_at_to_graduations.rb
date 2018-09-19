# frozen_string_literal: true

class AddDateInfoSentAtToGraduations < ActiveRecord::Migration[4.2]
  def change
    add_column :graduations, :date_info_sent_at, :datetime
  end
end
