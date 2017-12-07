# frozen_string_literal: true

class Appointment < ApplicationRecord
  belongs_to :member
  belongs_to :role

  scope :current, -> {
    where('"from" <= ? AND ("to" IS NULL OR "to" >= ?)', *([Date.current] * 2))
  }

  validates :from, :member_id, :role_id, presence: true

  def label
    if guardian_index
      "#{member.guardians[guardian_index][:name]} (for #{member.name})"
    else
      member.name
    end
  end

  def appointed_name
    if guardian_index
      member.guardians[guardian_index][:name]
    else
      member.name
    end
  end

  def appointed_first_name
    if guardian_index
      member.guardians[guardian_index][:name].split(/\s+/).first
    else
      member.first_name
    end
  end

  def elected_contact
    (guardian_index && member.guardians[guardian_index]) ||
        { name: member.name, email: member.email || member.emails.first }
  end
end
