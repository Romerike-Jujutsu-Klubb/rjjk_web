# frozen_string_literal: true

class MakeMembersJoinedOnRequired < ActiveRecord::Migration[4.2]
  def up
    change_column_null :members, :joined_on, false
  end

  def down
    change_column_null :members, :joined_on, true
  end
end
