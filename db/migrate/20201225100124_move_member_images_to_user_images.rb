# frozen_string_literal: true

class MoveMemberImagesToUserImages < ActiveRecord::Migration[6.0]
  def up
    MemberImage.all.each do |mi|
      UserImage.create! image_id: mi.image_id, user_id: mi.member.user_id, rel_type: :profile
      mi.destroy!
    end
    drop_table :member_images
  end

  class MemberImage < ApplicationRecord
    belongs_to :member
  end
end
