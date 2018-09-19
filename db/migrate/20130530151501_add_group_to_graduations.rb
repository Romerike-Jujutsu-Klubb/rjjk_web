# frozen_string_literal: true

class AddGroupToGraduations < ActiveRecord::Migration[4.2]
  def change
    add_column :graduations, :group_id, :integer
    Graduation.all.each do |graduation|
      graduation_groups = graduation.graduates.map(&:rank).map(&:group_id)
      if graduation_groups.empty?
        graduation.destroy
        next
      end
      group_id_freq = graduation_groups.group_by { |g| g }
      main_group_id = group_id_freq.values.max_by(&:size).first
      graduation.update! group_id: main_group_id
    end
    change_column_null :graduations, :group_id, false
    remove_column :graduations, :martial_art_id, :integer
  end

  class Graduation < ApplicationRecord
    has_many :graduates
  end

  class Graduate < ApplicationRecord
    belongs_to :rank
  end

  class Rank < ApplicationRecord
    belongs_to :group
  end

  class Group < ApplicationRecord
  end
end
