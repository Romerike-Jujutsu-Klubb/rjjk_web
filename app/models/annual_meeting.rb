class AnnualMeeting < ActiveRecord::Base
  attr_accessible :invitation_sent_at, :public_record_updated_at, :start_at
end
