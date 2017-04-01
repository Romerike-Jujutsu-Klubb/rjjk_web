# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.binary :content, null: false
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
