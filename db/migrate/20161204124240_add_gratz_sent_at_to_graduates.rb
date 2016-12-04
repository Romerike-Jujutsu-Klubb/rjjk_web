# frozen_string_literal: true
class AddGratzSentAtToGraduates < ActiveRecord::Migration
  def change
    add_column :graduates, :gratz_sent_at, :datetime
  end
end
