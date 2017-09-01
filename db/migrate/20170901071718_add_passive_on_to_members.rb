# frozen_string_literal: true

class AddPassiveOnToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :passive_on, :date
    today = Date.current
    Member.find_each { |m| m.update!(passive_on: today) if m.nkf_member&.medlemsstatus == 'P' }
  end

  class Member < ApplicationRecord
    has_one :nkf_member
    def name
      "#{first_name} #{last_name}"
    end
  end
  class NkfMember < ApplicationRecord
    belongs_to :member
  end
end
