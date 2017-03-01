# frozen_string_literal: true
class NkfMemberTrial < ActiveRecord::Base
  SEARCH_FIELDS = [:fornavn, :etternavn, :epost].freeze

  has_many :trial_attendances, dependent: :destroy

  scope :for_group, ->(group) { where('alder BETWEEN ? AND ?', group.from_age, group.to_age) }
  scope :search, ->(query) do
    where(SEARCH_FIELDS.map { |c| "UPPER(#{c}) LIKE ?" }.join(' OR '),
        *(["%#{UnicodeUtils.upcase(query)}%"] * SEARCH_FIELDS.size))
        .order(:fornavn, :etternavn).all
  end

  validates :alder, :epost, :etternavn, :fodtdato,
      :fornavn, :medlems_type, :postnr, :reg_dato, :stilart, :tid, presence: true
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
