class FixFutureBirthdates < ActiveRecord::Migration
  def self.up
    Member.where('birthdate > ?', Date.today).each do |m|
      new_birthdate = Date.new(m.birthdate.year - 100, m.birthdate.month, m.birthdate.day)
      puts "Moving birthdate: #{m.birthdate} => #{new_birthdate}"
      m.update_attributes! birthdate: new_birthdate
    end
  end

  def self.down
  end

  class Member < ActiveRecord::Base; end
end
