class NkfMemberTrial < ActiveRecord::Base
  SEARCH_FIELDS = [:fornavn, :etternavn, :epost]

  has_many :trial_attendances, dependent: :destroy

  scope :for_group, ->(group) { where('alder BETWEEN ? AND ?', group.from_age, group.to_age) }
  scope :search, ->(query) do
    where(SEARCH_FIELDS.map { |c| "UPPER(#{c}) LIKE ?" }.join(' OR '),
        *(["%#{UnicodeUtils.upcase(query)}%"] * SEARCH_FIELDS.size))
        .order(:fornavn, :etternavn).all
  end

  validates_presence_of :alder, :epost, :etternavn, :fodtdato,
      :fornavn, :medlems_type, :postnr, :reg_dato, :sted, :stilart, :tid
  validates_inclusion_of :res_sms, in: [true, false]

  def age
    age = Date.today.year - fodtdato.year
    age -= 1 if Date.today < fodtdato + age.years
    age
  end

  def name
    "#{fornavn} #{etternavn}"
  end

  def group
    Group.active(Date.today).to_a.find { |g| g.contains_age age }
  end

  def emails
    [epost, epost_faktura].compact.map(&:strip).uniq.sort
  end
end
