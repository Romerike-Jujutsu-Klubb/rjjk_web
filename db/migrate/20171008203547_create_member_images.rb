# frozen_string_literal: true

class CreateMemberImages < ActiveRecord::Migration[5.1]
  def change
    create_table :member_images do |t|
      t.references :member, foreign_key: true, null: false
      t.references :image, foreign_key: true, null: false
      t.index %i[member_id image_id], unique: true
      t.timestamps
    end
    Member.all.each do |member|
      if member.image_id && Image.where(id: member.image_id).exists?
        MemberImage.create! member_id: member.id, image_id: member.image_id
      end
    end
    remove_column :members, :image_id, :integer
  end

  class Image < ApplicationRecord; end
  class Member < ApplicationRecord; end
  class MemberImage < ApplicationRecord; end
end
