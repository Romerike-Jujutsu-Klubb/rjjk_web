# frozen_string_literal: true

class AddGratzSentAtToGraduates < ActiveRecord::Migration
  def change
    add_column :graduates, :gratz_sent_at, :datetime
    reversible do |dir|
      dir.up do
        execute "UPDATE graduates SET gratz_sent_at = created_at WHERE created_at < '2016-08-01'"
      end
    end
  end
end
