class NkfMember < ActiveRecord::Base
  belongs_to :member
  
  validates_uniqueness_of :member_id, :allow_nil => true
  
  def self.find_free_members
    Member.find(
      :all, 
      :conditions => "(left_on IS NULL OR left_on >= '2000-12-01') AND id NOT IN (SELECT member_id FROM nkf_members WHERE member_id IS NOT NULL)",
      :order => 'first_name, last_name'
    )
  end
  
end
