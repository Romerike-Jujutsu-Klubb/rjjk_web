# frozen_string_literal: true
class CreateRanks < ActiveRecord::Migration
  def self.up
    create_table :martial_arts, force: true do |t|
      t.column :name, :string, limit: 16, null: false
    end
    create_table :ranks, force: true  do |t|
      t.column :name, :string, limit: 16, null: false
      t.column :colour, :string, limit: 16, null: false
      t.column :position, :integer, null: false
      t.column :martial_art_id, :integer, null: false
    end
    create_table :graduations, force: true do |t|
      t.column :held_on, :date, null: false
      t.column :martial_art_id, :integer, null: false
    end
    create_table :censors, force: true do |t|
      t.column :graduation_id, :integer, null: false
      t.column :member_id, :integer, null: false
    end
    create_table :graduates, force: true do |t|
      t.column :member_id, :integer, null: false
      t.column :graduation_id, :integer, null: false
      t.column :passed, :boolean, null: false
      t.column :rank_id, :integer, null: false
      t.column :paid_graduation, :boolean, null: false
      t.column :paid_belt, :boolean, null: false
    end

    MartialArt.create! name: 'Kei Wa Ryu'
    MartialArt.create! name: 'Aikikai'
  end

  def self.down
    drop_table :graduates
    drop_table :censors
    drop_table :graduations
    drop_table :ranks
    drop_table :martial_arts
  end

  class MartialArt < ActiveRecord::Base; end
end
