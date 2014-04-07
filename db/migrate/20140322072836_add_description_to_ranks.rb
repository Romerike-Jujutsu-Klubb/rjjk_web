class AddDescriptionToRanks < ActiveRecord::Migration
  def change
    add_column :ranks, :description, :text

    unless Rails.env.test?
      load "#{Rails.root}/import_techniques.rb"
    end
  end
end
