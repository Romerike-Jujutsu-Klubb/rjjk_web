# frozen_string_literal: true

class AddMartialArtsMembers < ActiveRecord::Migration
  def self.up
    create_table :martial_arts_members, id: false do |t|
      t.integer :martial_art_id, null: false
      t.integer :member_id, null: false
      t.timestamps
    end
    Member.all.each do |m|
      ma = MartialArt.find_by(family: m.department || 'Jujutsu')
      raise m.department if ma.nil?
      m.martial_arts << ma
      m.save!
    end
    remove_column :cms_members, :department
    remove_column :members, :department
  end

  def self.down
    add_column :members, :department, :string, limit: 100
    add_column :cms_members, :department, :string, limit: 100
    Member.all.each do |m|
      m.department = m.martial_arts[0].family
      m.save!
    end
    drop_table :martial_arts_members
  end

  class Member < ApplicationRecord; end
end
