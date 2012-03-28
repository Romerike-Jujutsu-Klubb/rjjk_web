class NkfMemberTrial < ActiveRecord::Base
  has_many :trial_attendances

  validates_presence_of :alder, :epost, :etternavn, :fodtdato,
                        :fornavn, :medlems_type, :postnr, :reg_dato, :sted, :stilart, :tid
  validates_inclusion_of :res_sms, :in => [true, false]

  def age
    age = Date.today.year - fodtdato.year
    age -= 1 if Date.today < fodtdato + age.years
    age
  end

end
