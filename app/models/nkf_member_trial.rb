# frozen_string_literal: true

class NkfMemberTrial < ApplicationRecord
  include Searching

  has_many :trial_attendances, dependent: :destroy

  scope :for_group, ->(group) { where('alder BETWEEN ? AND ?', group.from_age, group.to_age) }

  search_scope %i[fornavn etternavn epost], order: %i[fornavn etternavn]

  validates_presence_of :alder, :epost, :etternavn, :fodtdato, :fornavn, :medlems_type, :postnr, :reg_dato,
      :stilart, :tid
  validates :res_sms, inclusion: { in: [true, false] }

  def age
    age = Date.current.year - fodtdato.year
    age -= 1 if Date.current < fodtdato + age.years
    age
  end

  def name
    "#{fornavn} #{etternavn}"
  end

  def group
    Group.active(Date.current).to_a.find { |g| g.contains_age age }
  end

  def emails
    [epost, epost_faktura].compact.map(&:strip).uniq.sort
  end
end
