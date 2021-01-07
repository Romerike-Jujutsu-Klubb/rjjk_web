# frozen_string_literal: true

class Signup < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, -> { with_deleted }, inverse_of: :signups
  has_one :member, through: :user

  scope :for_group, ->(group) {
    includes(user: :groups).references(:users)
        .where('(groups.id IS NULL AND users.birthdate BETWEEN ? AND ?) OR (groups.id = ?)',
            group.to_age.years.ago, group.from_age.years.ago, group.id)
        .order(:created_at, :first_name, :last_name)
  }

  validates :user_id, presence: true
  validate { errors.add(:user_id, 'is already a member') if user.member }

  def to_s
    user.name
  end
end
