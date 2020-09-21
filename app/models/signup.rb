# frozen_string_literal: true

class Signup < ApplicationRecord
  belongs_to :nkf_member_trial
  belongs_to :user, -> { with_deleted }, inverse_of: :signups

  validates :user_id, presence: true
  validates :nkf_member_trial_id, presence: true, uniqueness: true
end
