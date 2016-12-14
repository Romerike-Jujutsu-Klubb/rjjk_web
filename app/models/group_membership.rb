# frozen_string_literal: true
class GroupMembership < ActiveRecord::Base
  belongs_to :group
  belongs_to :member, -> { where('left_on IS NULL OR left_on > DATE(CURRENT_TIMESTAMP)') }

  validates :group_id, :member_id, presence: true
end
