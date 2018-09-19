# frozen_string_literal: true

class FixFutureBirthdates < ActiveRecord::Migration[4.2]
  def self.up
    Member.where('birthdate > ?', Date.current).each do |m|
      new_birthdate = Date.new(m.birthdate.year - 100, m.birthdate.month, m.birthdate.day)
      m.update! birthdate: new_birthdate
    end
  end

  def self.down; end

  class Member < ApplicationRecord; end
end
