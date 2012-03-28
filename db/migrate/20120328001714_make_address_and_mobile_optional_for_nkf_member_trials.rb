class MakeAddressAndMobileOptionalForNkfMemberTrials < ActiveRecord::Migration
  def up
    change_column_null :nkf_member_trials, :adresse, true
    change_column_null :nkf_member_trials, :mobil, true
  end

  def down
    change_column_null :nkf_member_trials, :mobil, false
    change_column_null :nkf_member_trials, :adresse, false
  end
end
