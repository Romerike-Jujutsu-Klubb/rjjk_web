# frozen_string_literal: true

class AddTimestampsToImages < ActiveRecord::Migration
  def up
    add_column :images, :created_at, :datetime
    add_column :images, :updated_at, :datetime
    now_formatted = Time.now.utc.strftime '%Y-%m-%d %H:%M'
    execute "UPDATE images SET created_at = '#{now_formatted}' WHERE created_at IS NULL"
    execute "UPDATE images SET updated_at = '#{now_formatted}' WHERE updated_at IS NULL"
  end

  def down
    remove_column :images, :updated_at
    remove_column :images, :created_at
  end
end
