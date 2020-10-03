# frozen_string_literal: true

class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :group_id, :user_id, presence: true
end
