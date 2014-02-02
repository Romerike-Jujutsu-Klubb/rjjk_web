class AnnualMeeting < ActiveRecord::Base
  attr_accessible :invitation_sent_at, :public_record_updated_at, :start_at

  validate do
    if id && start_at && self.class.
        where('id <> ? AND EXTRACT(YEAR FROM start_at) = ?', id, start_at.year).
        exists?
      errors.add(:start_at, 'kan bare ha et årsmøte per år.')
    end
  end
end
