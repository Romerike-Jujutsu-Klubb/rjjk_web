class AddMembers < ActiveRecord::Migration
  def self.up
    create_table "members", :force => true do |t|
      t.column :first_name,         :string,  :limit => 100,                                :default => "",     :null => false
      t.column :last_name,          :string,  :limit => 100,                                :default => "",     :null => false
      t.column :senior,             :boolean, :default => false,     :null => false
      t.column :email,              :string,  :limit => 128
      t.column :phone_mobile,       :string, :limit => 32
      t.column :phone_home,         :string, :limit => 32
      t.column :phone_work,         :string, :limit => 32
      t.column :phone_parent,       :string, :limit => 32
      t.column :birtdate,           :date
      t.column :male,               :boolean, :null => false
      t.column :joined_on,          :date
      t.column :contract_id,        :integer
      t.column :department ,        :string,  :limit => 100      
      t.column :cms_contract_id,    :integer
      t.column :left_on,            :date
      t.column :parent_name,        :string,  :limit => 100
      t.column :address,            :string,  :limit => 100,                                :default => "",     :null => false
      t.column :postal_code,        :string,  :limit => 4, :null => false
      t.column :billing_type,       :string,  :limit => 100
      t.column :billing_name,       :string,  :limit => 100
      t.column :billing_address,    :string,  :limit => 100
      t.column :billing_postal_code,:string,  :limit => 4
      t.column :payment_problem,    :boolean,                                                                   :null => false
      t.column :comment,            :string
      t.column :instructor,         :boolean, :null => false
      t.column :nkf_fee,            :boolean, :null => false
    end
    Member.create :first_name => 'Uwe',
                  :last_name => 'Kubosch',
                  :senior => true,
                  :email => 'uwe@kubosch.no',
                  :phone_mobile => '92206046',
                  :birtdate => '1970-11-25',
                  :male => true,
                  :joined_on => '1986-01-12',
                  :address => 'Møllesvingen 5',
                  :postal_code => '2006',
                  :billing_type => 'AutoGiro',
                  :payment_problem => false,
                  :comment => 'Kul kar',
                  :instructor => true,
                  :nkf_fee => true
                  
    Member.create :first_name => 'Lars',
                  :last_name => 'Bråten',
                  :senior => true,
                  :email => 'lars@bratens.net',
                  :phone_mobile => '91735210',
                  :birtdate => '1968-03-24',
                  :male => true,
                  :joined_on => '1984-01-12',
                  :address => 'Torsvei 8b',
                  :postal_code => '1472',
                  :billing_type => 'AutoGiro',
                  :payment_problem => false,
                  :comment => 'Veldig kul kar',
                  :instructor => false,
                  :nkf_fee => true
                  
    Member.create :first_name => 'Hans Petter',
                  :last_name => 'Grimstad',
                  :senior => true,
                  :email => 'petter@ptype.net',
                  :phone_mobile => '',
                  :birtdate => '1970-06-23',
                  :male => true,
                  :joined_on => '1986-01-12',
                  :left_on => '1986-12-12',
                  :address => 'Tyrivn 3b',
                  :postal_code => '1470',
                  :billing_type => 'AutoGiro',
                  :payment_problem => false,
                  :comment => 'Veldig gift kar',
                  :instructor => false,
                  :nkf_fee => true
                  
  end

  def self.down
    drop_table :members
  end
end
