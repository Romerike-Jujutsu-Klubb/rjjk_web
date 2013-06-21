# encoding: utf-8
class GroupSemester < ActiveRecord::Base
  attr_accessible :first_session, :group_id, :last_session, :semester_id

  belongs_to :group
  belongs_to :semester

  validate do
    unless (semester.start_on..semester.end_on).include? first_session
      errors.add :first_session, 'må være innenfor dette semesteret.'
    end
    unless (semester.start_on..semester.end_on).include? last_session
      errors.add :last_session, 'må være innenfor dette semesteret.'
    end
  end

end
