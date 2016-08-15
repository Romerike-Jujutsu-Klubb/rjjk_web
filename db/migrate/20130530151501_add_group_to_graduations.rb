class AddGroupToGraduations < ActiveRecord::Migration
  def change
    add_column :graduations, :group_id, :integer
    Graduation.all.each do |graduation|
      graduation_groups = graduation.graduates.map(&:rank).map(&:group_id)
      if graduation_groups.empty?
        graduation.destroy
        next
      end
      group_id_freq = graduation_groups.group_by { |g| g }
      main_group_id = group_id_freq.values.sort_by(&:size).last.first
      graduation.update_attributes! group_id: main_group_id
    end
    change_column_null :graduations, :group_id, false
    remove_column :graduations, :martial_art_id
  end

  class Graduation < ActiveRecord::Base
    has_many :graduates
  end

  class Graduate < ActiveRecord::Base
    belongs_to :rank
  end

  class Rank < ActiveRecord::Base
    belongs_to :group
  end

  class Group < ActiveRecord::Base
  end
end
