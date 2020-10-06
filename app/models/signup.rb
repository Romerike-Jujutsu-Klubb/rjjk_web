# frozen_string_literal: true

class Signup < ApplicationRecord
  belongs_to :nkf_member_trial
  belongs_to :user, -> { with_deleted }, inverse_of: :signups

  scope :for_group, ->(group) {
    includes(user: :groups).references(:users)
        .where('(users.birthdate BETWEEN ? AND ?) OR (groups.id = ?)',
            group.to_age.years.ago, group.from_age.years.ago, group.id)
        .order(:created_at, :first_name, :last_name)
  }

  validates :user_id, presence: true
  validates :nkf_member_trial_id, presence: true, uniqueness: true
end
