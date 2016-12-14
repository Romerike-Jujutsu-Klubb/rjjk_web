# frozen_string_literal: true
class FixFutureBirthdates < ActiveRecord::Migration
  def self.up
    Member.where('birthdate > ?', Date.current).each do |m|
      new_birthdate = Date.new(m.birthdate.year - 100, m.birthdate.month, m.birthdate.day)
      m.update_attributes! birthdate: new_birthdate
    end
  end

  def self.down
  end

  class Member < ActiveRecord::Base; end
end
