class ExpandNkfMemberMobiles < ActiveRecord::Migration[5.1]
  def change
    change_column :nkf_members, :foresatte_mobil, :string, limit: 255
    change_column :nkf_members, :foresatte_nr_2_mobil, :string, limit: 255
  end
end
