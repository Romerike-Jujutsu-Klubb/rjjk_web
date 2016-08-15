class CmsMember < ActiveRecord::Base
  ACTIVE_CONDITIONS = "left_on IS NULL or left_on > DATE(CURRENT_TIMESTAMP)"

  validates_presence_of :address, :first_name, :last_name, :postal_code
  validates_inclusion_of(:instructor, :male, :nkf_fee, :payment_problem, in: [true, false])
  validates_length_of :postal_code, is: 4
  validates_length_of :billing_postal_code, is: 4, if: :billing_postal_code
  validates_uniqueness_of :cms_contract_id

  def self.find_active
    where(ACTIVE_CONDITIONS).order(:last_name, :first_name)
  end

  def self.find_inactive
    where("not (#{ACTIVE_CONDITIONS})").order(:last_name, :first_name)
  end

  def fee
    if instructor?
      0
    elsif senior?
      300 + nkf_fee_amount
    else
      260 + nkf_fee_amount
    end
  end

  def senior?
    birthdate && (age >= Member::JUNIOR_AGE_LIMIT)
  end

  def age
    birthdate && ((Date.today - birthdate).to_i / 365)
  end

  def gender
    if male
        "Mann"
    else
        "Kvinne"
    end
  end

  def nkf_fee_amount
    if senior?
     (nkf_fee? ? (279.0 / 12).ceil : 0)
    else
     (nkf_fee? ? (155.0 / 12).ceil : 0)
    end
  end
end
