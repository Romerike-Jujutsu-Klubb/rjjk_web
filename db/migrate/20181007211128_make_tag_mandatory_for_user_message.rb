# frozen_string_literal: true

class MakeTagMandatoryForUserMessage < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up { execute "UPDATE user_messages SET tag = 'censor_missing_approval' WHERE tag IS NULL" }
    end
    change_column_null :user_messages, :tag, false
  end
end
