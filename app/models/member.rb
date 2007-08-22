class Member < ActiveRecord::Base
  #validates_presence_of :first_name, :last_name, :birthdate, :male, :join_on, :address, :postal_code
  
  def self.find_active()
    Member.find(:all, :conditions => "left_on IS NULL")
  end
  
  def fee
    if instructor?
      0
    elsif senior?
      300 + nkf_fee
    else
      260 + nkf_fee
    end
  end

  def nkf_fee
     if senior?
       (nkf_fee? ? (279.0 / 12).ceil : 0)
     else
       (nkf_fee? ? (155.0 / 12).ceil : 0)  
     end
   end
  
end
