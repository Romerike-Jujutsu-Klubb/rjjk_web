# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080824192346) do

  create_table "censors", :force => true do |t|
    t.integer "graduation_id", :null => false
    t.integer "member_id",     :null => false
  end

  create_table "cms_members", :force => true do |t|
    t.string   "first_name",           :limit => 100, :default => "",    :null => false
    t.string   "last_name",            :limit => 100, :default => "",    :null => false
    t.boolean  "senior",                              :default => false, :null => false
    t.string   "email",                :limit => 128
    t.string   "phone_mobile",         :limit => 32
    t.string   "phone_home",           :limit => 32
    t.string   "phone_work",           :limit => 32
    t.string   "phone_parent",         :limit => 32
    t.date     "birtdate"
    t.boolean  "male",                                                   :null => false
    t.date     "joined_on"
    t.integer  "contract_id"
    t.string   "department",           :limit => 100
    t.integer  "cms_contract_id"
    t.date     "left_on"
    t.string   "parent_name",          :limit => 100
    t.string   "address",              :limit => 100, :default => "",    :null => false
    t.string   "postal_code",          :limit => 4,                      :null => false
    t.string   "billing_type",         :limit => 100
    t.string   "billing_name",         :limit => 100
    t.string   "billing_address",      :limit => 100
    t.string   "billing_postal_code",  :limit => 4
    t.boolean  "payment_problem",                                        :null => false
    t.string   "comment"
    t.boolean  "instructor",                                             :null => false
    t.boolean  "nkf_fee",                                                :null => false
    t.string   "social_sec_no",        :limit => 11
    t.string   "account_no",           :limit => 16
    t.string   "billing_phone_home",   :limit => 32
    t.string   "billing_phone_mobile", :limit => 32
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "graduates", :force => true do |t|
    t.integer "member_id",       :null => false
    t.integer "graduation_id",   :null => false
    t.boolean "passed",          :null => false
    t.integer "rank_id",         :null => false
    t.boolean "paid_graduation", :null => false
    t.boolean "paid_belt",       :null => false
  end

  create_table "graduations", :force => true do |t|
    t.date    "held_on",        :null => false
    t.integer "martial_art_id", :null => false
  end

  create_table "images", :force => true do |t|
    t.string "name",         :limit => 64, :null => false
    t.string "content_type",               :null => false
    t.binary "content_data",               :null => false
  end

  create_table "information_pages", :force => true do |t|
    t.integer  "parent_id"
    t.string   "title",      :limit => 32, :null => false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "martial_arts", :force => true do |t|
    t.string "name", :limit => 16, :null => false
  end

  create_table "members", :force => true do |t|
    t.string  "first_name",           :limit => 100, :default => "",    :null => false
    t.string  "last_name",            :limit => 100, :default => "",    :null => false
    t.boolean "senior",                              :default => false, :null => false
    t.string  "email",                :limit => 128
    t.string  "phone_mobile",         :limit => 32
    t.string  "phone_home",           :limit => 32
    t.string  "phone_work",           :limit => 32
    t.string  "phone_parent",         :limit => 32
    t.date    "birtdate"
    t.boolean "male",                                                   :null => false
    t.date    "joined_on"
    t.integer "contract_id"
    t.string  "department",           :limit => 100
    t.integer "cms_contract_id"
    t.date    "left_on"
    t.string  "parent_name",          :limit => 100
    t.string  "address",              :limit => 100, :default => "",    :null => false
    t.string  "postal_code",          :limit => 4,                      :null => false
    t.string  "billing_type",         :limit => 100
    t.string  "billing_name",         :limit => 100
    t.string  "billing_address",      :limit => 100
    t.string  "billing_postal_code",  :limit => 4
    t.boolean "payment_problem",                                        :null => false
    t.string  "comment"
    t.boolean "instructor",                                             :null => false
    t.boolean "nkf_fee",                                                :null => false
    t.string  "social_sec_no",        :limit => 11
    t.string  "account_no",           :limit => 16
    t.string  "billing_phone_home",   :limit => 32
    t.string  "billing_phone_mobile", :limit => 32
  end

  create_table "news_items", :force => true do |t|
    t.string   "title",      :limit => 64, :null => false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ranks", :force => true do |t|
    t.string  "name",           :limit => 16, :null => false
    t.string  "colour",         :limit => 16, :null => false
    t.integer "position",                     :null => false
    t.integer "martial_art_id",               :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login",           :limit => 80,                    :null => false
    t.string   "salted_password", :limit => 40,                    :null => false
    t.string   "email",           :limit => 60,                    :null => false
    t.string   "first_name",      :limit => 40
    t.string   "last_name",       :limit => 40
    t.string   "salt",            :limit => 40,                    :null => false
    t.string   "role",            :limit => 40
    t.string   "security_token",  :limit => 40
    t.datetime "token_expiry"
    t.boolean  "verified",                      :default => false
    t.boolean  "deleted",                       :default => false
  end

end
