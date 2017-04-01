# frozen_string_literal: true

class CmsMember < ActiveRecord::Base
  ACTIVE_CONDITIONS = 'left_on IS NULL or left_on > DATE(CURRENT_TIMESTAMP)'

  validates :address, :first_name, :last_name, :postal_code, presence: true
  validates(:instructor, :male, :nkf_fee, :payment_problem, inclusion: { in: [true, false] })
  validates :postal_code, length: { is: 4 }
  validates :billing_postal_code, length: { is: 4, if: :billing_postal_code }
  validates :cms_contract_id, uniqueness: true

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
    birthdate && ((Date.current - birthdate).to_i / 365)
  end

  def gender
    if male
      'Mann'
    else
      'Kvinne'
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
