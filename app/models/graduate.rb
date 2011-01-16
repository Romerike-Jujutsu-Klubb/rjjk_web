class Graduate < ActiveRecord::Base
  belongs_to :graduation
  belongs_to :member
  belongs_to :rank

  validates_uniqueness_of :member_id, :scope => :graduation_id
  validates_uniqueness_of :member_id, :scope => :rank_id
end
