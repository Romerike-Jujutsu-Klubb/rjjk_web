class CmsMember < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :address, :postal_code, :cms_contract_id
  validates_inclusion_of(:payment_problem, :in => [true, false])
  validates_inclusion_of(:male, :in => [true, false])
  validates_length_of :postal_code, :is => 4
  validates_length_of :billing_postal_code, :is => 4, :if => :billing_postal_code
  validates_uniqueness_of :cms_contract_id
end
