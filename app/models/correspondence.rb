class Correspondence < ActiveRecord::Base
  attr_accessible :member_id, :related_model_id, :sent_at

  belongs_to :member
end
