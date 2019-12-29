# frozen_string_literal: true

class MoveSignatureToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :signatures, :user, foreign_key: true
    Signature.all.each do |s|
      m = Member.find(s.member_id)
      s.update! user_id: m.user_id
    end
    remove_column :signatures, :member_id, :bigint
  end
end
