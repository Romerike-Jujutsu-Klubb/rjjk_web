class MemberImage < ActiveRecord::Base
  belongs_to :member
  belongs_to :image
end
