class AddGuardianToNkfMember < ActiveRecord::Migration
  def change
    add_column :nkf_members, :foresatte, :string, :limit => 64
    add_column :nkf_members, :foresatte_epost, :string, :limit => 32
    add_column :nkf_members, :foresatte_mobil, :string, :limit => 16
    add_column :nkf_members, :foresatte_nr_2, :string, :limit => 64
    add_column :nkf_members, :foresatte_nr_2_mobil, :string, :limit => 16
  end
end
