class Correspondence < ActiveRecord::Base
  attr_accessible :member_id, :related_id, :sent_at
end
