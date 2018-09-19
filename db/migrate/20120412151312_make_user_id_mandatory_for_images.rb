# frozen_string_literal: true

class MakeUserIdMandatoryForImages < ActiveRecord::Migration[4.2]
  def up
    execute 'UPDATE images SET user_id = 1 WHERE user_id IS NULL'
    change_column_null :images, :user_id, false
  end

  def down
    change_column_null :images, :user_id, true
  end
end
