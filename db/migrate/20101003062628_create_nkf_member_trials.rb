class CreateNkfMemberTrials < ActiveRecord::Migration
  def self.up
    create_table :nkf_member_trials do |t|
      t.string :medlems_type, :limit => 16, :null => false
      t.string :etternavn,    :limit => 32, :null => false
      t.string :fornavn,      :limit => 32, :null => false
      t.date :fodtdato,                     :null => false
      t.integer :alder,                     :null => false
      t.string :postnr,       :limit => 4,  :null => false
      t.string :sted,         :limit => 32, :null => false
      t.string :adresse,      :limit => 64, :null => false
      t.string :epost,        :limit => 64, :null => false
      t.string :mobil,        :limit => 16, :null => false
      t.boolean :res_sms,                   :null => false
      t.date :reg_dato,                     :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :nkf_member_trials
  end
end
