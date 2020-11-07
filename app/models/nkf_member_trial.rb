# frozen_string_literal: true

class NkfMemberTrial < ApplicationRecord
  include NkfAttributeConversion
  include Searching

  has_one :signup, dependent: :nullify
  has_one :user, through: :signup

  scope :for_group, ->(group) {
    where('fodselsdato BETWEEN ? AND ?', group.to_age.years.ago, group.from_age.years.ago)
        .order(:innmeldtdato, :fornavn, :etternavn)
  }

  search_scope %i[fornavn etternavn epost], order: %i[fornavn etternavn]

  validates :epost, :etternavn, :fodselsdato, :fornavn, :postnr, :innmeldtdato,
      :gren_stilart_avd_parti___gren_stilart_avd_parti, :reg_dato, :tid,
      presence: true
  validates :kjonn, inclusion: { in: %w[M K I] }

  def member
    nil
  end

  def age
    age = Date.current.year - fodselsdato.year
    age -= 1 if Date.current < fodselsdato + age.years
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

  def to_s
    name
  end
end
