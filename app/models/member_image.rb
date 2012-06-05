class MemberImage < ActiveRecord::Base
  attr_accessible :content_type, :data, :filename, :member_id
  belongs_to :member

  def format
    filename.split('.').last
  end

end
