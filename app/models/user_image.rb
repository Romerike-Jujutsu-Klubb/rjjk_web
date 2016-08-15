class UserImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :image

  validates_uniqueness_of :image_id, scope: [:rel_type, :user_id]
end
