# frozen_string_literal: true

class AddDescriptionToRanks < ActiveRecord::Migration[4.2]
  def change
    add_column :ranks, :description, :text
    load "#{Rails.root}/import_techniques.rb" unless Rails.env.test?
  end
end
