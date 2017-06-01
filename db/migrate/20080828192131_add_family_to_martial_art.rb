# frozen_string_literal: true

class AddFamilyToMartialArt < ActiveRecord::Migration
  def self.up
    add_column :martial_arts, :family, :string, limit: 16, null: false, default: 'Jujutsu'
    change_column :martial_arts, :family, :string, default: nil
    ma = MartialArt.find_by(name: 'Aikikai')
    ma&.update! family: 'Aikido'
  end

  def self.down
    remove_column :martial_arts, :family
  end

  class MartialArt < ApplicationRecord; end
end
