# frozen_string_literal: true

class AddHonoraryMemberToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :honorary_on, :datetime
  end
end
