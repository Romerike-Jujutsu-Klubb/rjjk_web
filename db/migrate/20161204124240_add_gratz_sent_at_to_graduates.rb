# frozen_string_literal: true

class AddGratzSentAtToGraduates < ActiveRecord::Migration
  def change
    add_column :graduates, :gratz_sent_at, :datetime
    execute "UPDATE graduates SET gratz_sent_at = created_at WHERE created_at < '2016-08-01'"
  end
end
