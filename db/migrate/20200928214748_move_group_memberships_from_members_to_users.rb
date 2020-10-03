# frozen_string_literal: true

class MoveGroupMembershipsFromMembersToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :group_memberships, :user, foreign_key: true
    add_column :group_memberships, :created_at, :datetime
    add_column :group_memberships, :updated_at, :datetime
    add_index :group_memberships, %w[group_id user_id], unique: true
    reversible do |dir|
      dir.up do
        GroupMembership.all.each do |gm|
          if GroupMembership.exists?(user_id: gm.member.user_id, group_id: gm.group_id)
            gm.destroy!
          else
            gm.update!(user_id: gm.member.user_id)
          end
        end
      end
      dir.down do
        GroupMembership.all.each do |gm|
          if gm.user.member
            gm.update!(member_id: gm.user.member.id)
          else
            gm.destroy!
          end
        end
        change_column_null :group_memberships, :member_id, false
      end
    end
    change_column_null :group_memberships, :user_id, false
    remove_column :group_memberships, :member_id, :bigint
  end

  class GroupMembership < ApplicationRecord
    belongs_to :group
    belongs_to :member
    belongs_to :user

    validates :group_id, :member_id, presence: true
  end
end
