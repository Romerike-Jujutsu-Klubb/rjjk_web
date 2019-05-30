# frozen_string_literal: true

class AddDateInfoSentForToGraduations < ActiveRecord::Migration[5.2]
  def change
    add_column :graduations, :date_info_sent_for, :date
    reversible do |dir|
      dir.up do
        execute('UPDATE graduations SET date_info_sent_for = held_on WHERE date_info_sent_at IS NOT NULL')
      end
    end
  end
end
