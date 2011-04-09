class NkfMemberTrial < ActiveRecord::Base
  has_many :trial_attendances

  def age
    age = Date.today.year - fodtdato.year
    age -= 1 if Date.today < fodtdato + age.years
    age
  end

end
