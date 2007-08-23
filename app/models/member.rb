class Member < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :address, :postal_code
  #validates_presence_of :birthdate, :join_on
  validates_inclusion_of(:payment_problem, :in => [true, false])
  validates_inclusion_of(:male, :in => [true, false])
  
  def self.find_active()
    Member.find(:all, :conditions => "left_on IS NULL", :order => 'last_name, first_name')
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
