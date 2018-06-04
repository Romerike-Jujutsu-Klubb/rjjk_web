# frozen_string_literal: true

class Appointment < ApplicationRecord
  belongs_to :member
  belongs_to :role

  scope :current, -> {
    where('"from" <= ? AND ("to" IS NULL OR "to" >= ?)', *([Date.current] * 2))
  }

  validates :from, :member_id, :role_id, presence: true

  def label
    member.name
  end

  def appointed_name
    member.name
  end

  def appointed_first_name
    member.first_name
  end

  def elected_contact
    { name: member.name, email: member.email || member.emails.first }
  end
end
