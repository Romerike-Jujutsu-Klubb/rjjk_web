# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 9) do

  create_table "censors", :force => true do |t|
    t.column "graduation_id", :integer, :null => false
    t.column "member_id",     :integer, :null => false
  end

  create_table "graduates", :force => true do |t|
    t.column "member_id",       :integer, :null => false
    t.column "graduation_id",   :integer, :null => false
    t.column "passed",          :boolean, :null => false
    t.column "rank_id",         :integer, :null => false
    t.column "paid_graduation", :boolean, :null => false
    t.column "paid_belt",       :boolean, :null => false
  end

  create_table "graduations", :force => true do |t|
    t.column "held_on",        :date,    :null => false
    t.column "martial_art_id", :integer, :null => false
  end

  create_table "images", :force => true do |t|
    t.column "name",         :string, :limit => 64, :null => false
    t.column "content_type", :string,               :null => false
    t.column "content_data", :binary,               :null => false
  end

  create_table "information_pages", :force => true do |t|
    t.column "parent_id",  :integer
    t.column "title",      :string,   :limit => 32, :null => false
    t.column "body",       :text
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "martial_arts", :force => true do |t|
    t.column "name", :string, :limit => 16, :null => false
  end

  create_table "members", :force => true do |t|
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
    t.column "contract_id",          :integer
    t.column "department",           :string,  :limit => 100
    t.column "cms_contract_id",      :integer
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
  end

  create_table "news_items", :force => true do |t|
    t.column "title",      :string,   :limit => 64, :null => false
    t.column "body",       :text
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "ranks", :force => true do |t|
    t.column "name",           :string,  :limit => 16, :null => false
    t.column "colour",         :string,  :limit => 16, :null => false
    t.column "position",       :integer,               :null => false
    t.column "martial_art_id", :integer,               :null => false
  end

  create_table "users", :force => true do |t|
    t.column "login",           :string,   :limit => 80,                    :null => false
    t.column "salted_password", :string,   :limit => 40,                    :null => false
    t.column "email",           :string,   :limit => 60,                    :null => false
    t.column "first_name",      :string,   :limit => 40
    t.column "last_name",       :string,   :limit => 40
    t.column "salt",            :string,   :limit => 40,                    :null => false
    t.column "role",            :string,   :limit => 40
    t.column "security_token",  :string,   :limit => 40
    t.column "token_expiry",    :datetime
    t.column "verified",        :boolean,                :default => false
    t.column "deleted",         :boolean,                :default => false
  end

  create_table "weights", :force => true do |t|
    t.column "weight", :decimal, :precision => 4, :scale => 1
  end

end
