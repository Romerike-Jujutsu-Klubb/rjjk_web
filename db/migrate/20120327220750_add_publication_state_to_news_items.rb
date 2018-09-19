# frozen_string_literal: true

class AddPublicationStateToNewsItems < ActiveRecord::Migration[4.2]
  def change
    add_column :news_items, :publication_state, :string, limit: 16, null: false,
                                                         default: 'PUBLISHED'
    change_column :news_items, :publication_state, :string, default: nil
  end
end
