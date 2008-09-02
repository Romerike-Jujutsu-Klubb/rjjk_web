class CreateCmsMembers < ActiveRecord::Migration
  def self.up
    create_table :cms_members do |t|
      t.column "first_name",           :string,  :limit => 100, :default => "",    :null => false
      t.column "last_name",            :string,  :limit => 100, :default => "",    :null => false
      t.column "senior",               :boolean,                :default => false, :null => false
      t.column "email",                :string,  :limit => 128
      t.column "phone_mobile",         :string,  :limit => 32
      t.column "phone_home",           :string,  :limit => 32
      t.column "phone_work",           :string,  :limit => 32
      t.column "phone_parent",         :string,  :limit => 32
      t.column "birtdate",             :date
      t.column "male",                 :boolean,                                   :null => false
      t.column "joined_on",            :date
      t.column "contract_id",          :integer, :references => nil
      t.column "department",           :string,  :limit => 100
      t.column "cms_contract_id",      :integer, :references => nil
      t.column "left_on",              :date
      t.column "parent_name",          :string,  :limit => 100
      t.column "address",              :string,  :limit => 100, :default => "",    :null => false
      t.column "postal_code",          :string,  :limit => 4,                      :null => false
      t.column "billing_type",         :string,  :limit => 100
      t.column "billing_name",         :string,  :limit => 100
      t.column "billing_address",      :string,  :limit => 100
      t.column "billing_postal_code",  :string,  :limit => 4
      t.column "payment_problem",      :boolean,                                   :null => false
      t.column "comment",              :string
      t.column "instructor",           :boolean,                                   :null => false
      t.column "nkf_fee",              :boolean,                                   :null => false
      t.column "social_sec_no",        :string,  :limit => 11
      t.column "account_no",           :string,  :limit => 16
      t.column "billing_phone_home",   :string,  :limit => 32
      t.column "billing_phone_mobile", :string,  :limit => 32
      
      t.timestamps
    end
    
    execute 'INSERT INTO cms_members SELECT * FROM members'
  end
  
  def self.down
    drop_table :cms_members
  end
end
