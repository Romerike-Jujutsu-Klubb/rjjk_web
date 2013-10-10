class NkfMemberTrial < ActiveRecord::Base
  has_many :trial_attendances, :dependent => :destroy

  validates_presence_of :alder, :epost, :etternavn, :fodtdato,
                        :fornavn, :medlems_type, :postnr, :reg_dato, :sted, :stilart, :tid
  validates_inclusion_of :res_sms, :in => [true, false]

  def age
    age = Date.today.year - fodtdato.year
    age -= 1 if Date.today < fodtdato + age.years
    age
  end

  def name
    "#{fornavn} #{etternavn}"
  end

  def self.find_by_contents(query, options = {})
    search_fields = [:fornavn, :etternavn, :epost]
    all({
            :conditions => [search_fields.map { |c| "UPPER(#{c}) LIKE ?" }.join(' OR '), *(["%#{UnicodeUtils.upcase(query)}%"] * search_fields.size)],
            :order => 'fornavn, etternavn',
        }.update(options))
  end

  def group
    Group.active(Date.today).all.find{|g|g.contains_age age}
  end
end
