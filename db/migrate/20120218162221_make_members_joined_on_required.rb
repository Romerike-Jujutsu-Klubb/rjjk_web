# frozen_string_literal: true
class MakeMembersJoinedOnRequired < ActiveRecord::Migration
  def up
    change_column_null :members, :joined_on, false
  end

  def down
    change_column_null :members, :joined_on, true
  end
end
