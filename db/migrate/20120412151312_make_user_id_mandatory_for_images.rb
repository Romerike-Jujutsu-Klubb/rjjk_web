# frozen_string_literal: true
class MakeUserIdMandatoryForImages < ActiveRecord::Migration
  def up
    execute 'UPDATE images SET user_id = 1 WHERE user_id IS NULL'
    change_column_null :images, :user_id, false
  end

  def down
    change_column_null :images, :user_id, true
  end
end
