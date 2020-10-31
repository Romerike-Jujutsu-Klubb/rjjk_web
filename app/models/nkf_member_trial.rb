# frozen_string_literal: true

class NkfMemberTrial < ApplicationRecord
  include Searching

  has_one :signup, dependent: :nullify

  scope :for_group, ->(group) {
    where('alder BETWEEN ? AND ?', group.from_age, group.to_age).order(:reg_dato, :fornavn, :etternavn)
  }

  search_scope %i[fornavn etternavn epost], order: %i[fornavn etternavn]

  validates :alder, :epost, :etternavn, :fodtdato, :fornavn, :medlems_type, :postnr, :reg_dato, :stilart,
      :tid, presence: true
  validates :kjonn, inclusion: { in: %w[M K I] }
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

  def to_s
    name
  end

  def user_attributes
    {
      address: adresse,
      birthdate: fodtdato,
      email: epost,
      first_name: fornavn,
      last_name: etternavn,
      male: kjonn == 'M',
      phone: mobil,
      postal_code: postnr,
    }
  end
end
