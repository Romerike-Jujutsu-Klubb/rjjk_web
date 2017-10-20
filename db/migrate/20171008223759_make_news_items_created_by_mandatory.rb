# frozen_string_literal: true

class MakeNewsItemsCreatedByMandatory < ActiveRecord::Migration[5.1]
  def change
    change_column_null :news_items, :created_by, false
  end
end
