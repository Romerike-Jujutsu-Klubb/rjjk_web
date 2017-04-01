# frozen_string_literal: true

class AddDateInfoSentAtToGraduations < ActiveRecord::Migration
  def change
    add_column :graduations, :date_info_sent_at, :datetime
  end
end
