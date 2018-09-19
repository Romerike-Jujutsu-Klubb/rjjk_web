# frozen_string_literal: true

class AddGroupNotificationToGraduations < ActiveRecord::Migration[4.2]
  def change
    add_column :graduations, :group_notification, :boolean, null: false, default: false
    reversible { |dir| dir.up { change_column_default :graduations, :group_notification, nil } }
  end
end
