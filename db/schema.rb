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

ActiveRecord::Schema.define(:version => 20101119183635) do

  create_table "attendances", :force => true do |t|
    t.integer  "member_id",         :limit => 10, :null => false
    t.integer  "group_schedule_id", :limit => 10, :null => false
    t.integer  "year",              :limit => 10, :null => false
    t.integer  "week",              :limit => 10, :null => false
    t.datetime "created_at",        :limit => 29
    t.datetime "updated_at",        :limit => 29
  end

  create_table "censors", :force => true do |t|
    t.integer "graduation_id", :limit => 10, :null => false
    t.integer "member_id",     :limit => 10, :null => false
  end

  create_table "cms_members", :force => true do |t|
    t.string   "first_name",           :limit => 100, :default => "", :null => false
    t.string   "last_name",            :limit => 100, :default => "", :null => false
    t.string   "email",                :limit => 128
    t.string   "phone_mobile",         :limit => 32
    t.string   "phone_home",           :limit => 32
    t.string   "phone_work",           :limit => 32
    t.string   "phone_parent",         :limit => 32
    t.date     "birthdate"
    t.boolean  "male",                                                :null => false
    t.date     "joined_on"
    t.integer  "contract_id",          :limit => 10
    t.integer  "cms_contract_id",      :limit => 10
    t.date     "left_on"
    t.string   "parent_name",          :limit => 100
    t.string   "address",              :limit => 100, :default => "", :null => false
    t.string   "postal_code",          :limit => 4,                   :null => false
    t.string   "billing_type",         :limit => 100
    t.string   "billing_name",         :limit => 100
    t.string   "billing_address",      :limit => 100
    t.string   "billing_postal_code",  :limit => 4
    t.boolean  "payment_problem",                                     :null => false
    t.string   "comment"
    t.boolean  "instructor",                                          :null => false
    t.boolean  "nkf_fee",                                             :null => false
    t.string   "social_sec_no",        :limit => 11
    t.string   "account_no",           :limit => 16
    t.string   "billing_phone_home",   :limit => 32
    t.string   "billing_phone_mobile", :limit => 32
    t.datetime "created_at",           :limit => 29
    t.datetime "updated_at",           :limit => 29
    t.string   "kid",                  :limit => 64
  end

  create_table "documents", :force => true do |t|
    t.binary   "content",    :limit => 2147483647, :null => false
    t.datetime "created_at", :limit => 29
    t.datetime "updated_at", :limit => 29
  end

  create_table "events", :force => true do |t|
    t.string   "name",        :limit => 64,         :null => false
    t.datetime "start_at",    :limit => 29,         :null => false
    t.datetime "end_at",      :limit => 29
    t.text     "description", :limit => 2147483647
    t.datetime "created_at",  :limit => 29
    t.datetime "updated_at",  :limit => 29
  end

  create_table "graduates", :force => true do |t|
    t.integer "member_id",       :limit => 10, :null => false
    t.integer "graduation_id",   :limit => 10, :null => false
    t.boolean "passed",                        :null => false
    t.integer "rank_id",         :limit => 10, :null => false
    t.boolean "paid_graduation",               :null => false
    t.boolean "paid_belt",                     :null => false
  end

  create_table "graduations", :force => true do |t|
    t.date    "held_on",                      :null => false
    t.integer "martial_art_id", :limit => 10, :null => false
  end

  create_table "group_schedules", :force => true do |t|
    t.integer  "group_id",   :limit => 10, :null => false
    t.integer  "weekday",    :limit => 10, :null => false
    t.time     "start_at",   :limit => 15, :null => false
    t.time     "end_at",     :limit => 15, :null => false
    t.datetime "created_at", :limit => 29
    t.datetime "updated_at", :limit => 29
  end

  create_table "groups", :force => true do |t|
    t.integer  "martial_art_id", :limit => 10, :null => false
    t.string   "name",                         :null => false
    t.integer  "from_age",       :limit => 10, :null => false
    t.integer  "to_age",         :limit => 10, :null => false
    t.datetime "created_at",     :limit => 29
    t.datetime "updated_at",     :limit => 29
  end

  create_table "groups_members", :id => false, :force => true do |t|
    t.integer "group_id",  :limit => 10, :null => false
    t.integer "member_id", :limit => 10, :null => false
  end

  add_index "groups_members", ["group_id", "member_id"], :name => "index_groups_members_on_group_id_and_member_id", :unique => true

  create_table "images", :force => true do |t|
    t.string "name",         :limit => 64,         :null => false
    t.string "content_type",                       :null => false
    t.binary "content_data", :limit => 2147483647, :null => false
  end

  create_table "information_pages", :force => true do |t|
    t.integer  "parent_id",  :limit => 10
    t.string   "title",      :limit => 32,         :null => false
    t.text     "body",       :limit => 2147483647
    t.datetime "created_at", :limit => 29
    t.datetime "updated_at", :limit => 29
    t.integer  "position",   :limit => 10
    t.boolean  "hidden"
  end

  create_table "martial_arts", :force => true do |t|
    t.string "name",   :limit => 16,                 :null => false
    t.string "family", :limit => 16, :default => "", :null => false
  end

  create_table "members", :force => true do |t|
    t.string   "first_name",           :limit => 100,        :default => "", :null => false
    t.string   "last_name",            :limit => 100,        :default => "", :null => false
    t.string   "email",                :limit => 128
    t.string   "phone_mobile",         :limit => 32
    t.string   "phone_home",           :limit => 32
    t.string   "phone_work",           :limit => 32
    t.string   "phone_parent",         :limit => 32
    t.date     "birthdate"
    t.boolean  "male",                                                       :null => false
    t.date     "joined_on"
    t.integer  "contract_id",          :limit => 10
    t.integer  "cms_contract_id",      :limit => 10
    t.date     "left_on"
    t.string   "parent_name",          :limit => 100
    t.string   "address",              :limit => 100,        :default => "", :null => false
    t.string   "postal_code",          :limit => 4,                          :null => false
    t.string   "billing_type",         :limit => 100
    t.string   "billing_name",         :limit => 100
    t.string   "billing_address",      :limit => 100
    t.string   "billing_postal_code",  :limit => 4
    t.boolean  "payment_problem",                                            :null => false
    t.string   "comment"
    t.boolean  "instructor",                                                 :null => false
    t.boolean  "nkf_fee",                                                    :null => false
    t.datetime "created_at",           :limit => 29
    t.datetime "updated_at",           :limit => 29
    t.string   "social_sec_no",        :limit => 11
    t.string   "account_no",           :limit => 16
    t.string   "billing_phone_home",   :limit => 32
    t.string   "billing_phone_mobile", :limit => 32
    t.string   "rfid",                 :limit => 25
    t.binary   "image",                :limit => 2147483647
    t.string   "image_name",           :limit => 64
    t.string   "image_content_type",   :limit => 32
    t.string   "kid",                  :limit => 64
  end

  create_table "news_items", :force => true do |t|
    t.string   "title",      :limit => 64,         :null => false
    t.text     "body",       :limit => 2147483647
    t.datetime "created_at", :limit => 29
    t.datetime "updated_at", :limit => 29
    t.integer  "created_by", :limit => 10
  end

  create_table "nkf_member_trials", :force => true do |t|
    t.string   "medlems_type",  :limit => 16, :null => false
    t.string   "etternavn",     :limit => 32, :null => false
    t.string   "fornavn",       :limit => 32, :null => false
    t.date     "fodtdato",                    :null => false
    t.integer  "alder",         :limit => 10, :null => false
    t.string   "postnr",        :limit => 4,  :null => false
    t.string   "sted",          :limit => 32, :null => false
    t.string   "adresse",       :limit => 64, :null => false
    t.string   "epost",         :limit => 64, :null => false
    t.string   "mobil",         :limit => 16, :null => false
    t.boolean  "res_sms",                     :null => false
    t.date     "reg_dato",                    :null => false
    t.datetime "created_at",    :limit => 29
    t.datetime "updated_at",    :limit => 29
    t.integer  "tid",           :limit => 10, :null => false
    t.string   "epost_faktura", :limit => 64
    t.string   "stilart",       :limit => 64, :null => false
  end

  add_index "nkf_member_trials", ["tid"], :name => "index_nkf_member_trials_on_tid", :unique => true

  create_table "nkf_members", :force => true do |t|
    t.integer  "member_id",                                       :limit => 10
    t.integer  "medlemsnummer",                                   :limit => 10
    t.string   "etternavn"
    t.string   "fornavn"
    t.string   "adresse_1"
    t.string   "adresse_2"
    t.string   "adresse_3"
    t.string   "postnr"
    t.string   "sted"
    t.string   "fodselsdato"
    t.string   "telefon"
    t.string   "telefon_arbeid"
    t.string   "mobil"
    t.string   "epost"
    t.string   "epost_faktura"
    t.string   "yrke"
    t.string   "medlemsstatus"
    t.string   "medlemskategori"
    t.string   "medlemskategori_navn"
    t.string   "kont_sats"
    t.string   "kont_belop"
    t.string   "kontraktstype"
    t.integer  "kontraktsbelop",                                  :limit => 10
    t.string   "rabatt"
    t.string   "gren_stilart_avd_parti___gren_stilart_avd_parti"
    t.string   "sist_betalt_dato"
    t.string   "betalt_t_o_m__dato"
    t.string   "konkurranseomrade_id"
    t.string   "konkurranseomrade_navn"
    t.string   "klubb_id"
    t.string   "klubb"
    t.integer  "hovedmedlem_id",                                  :limit => 10
    t.string   "hovedmedlem_navn"
    t.string   "innmeldtdato"
    t.string   "innmeldtarsak"
    t.string   "utmeldtdato"
    t.string   "utmeldtarsak"
    t.string   "antall_etiketter_1"
    t.datetime "created_at",                                      :limit => 29
    t.datetime "updated_at",                                      :limit => 29
    t.string   "ventekid",                                        :limit => 20
  end

  create_table "ranks", :force => true do |t|
    t.string  "name",            :limit => 16, :null => false
    t.string  "colour",          :limit => 48, :null => false
    t.integer "position",        :limit => 10, :null => false
    t.integer "martial_art_id",  :limit => 10, :null => false
    t.integer "standard_months", :limit => 10
  end

  create_table "trial_attendances", :force => true do |t|
    t.integer  "nkf_member_trial_id", :limit => 10, :null => false
    t.integer  "group_schedule_id",   :limit => 10, :null => false
    t.integer  "year",                :limit => 10, :null => false
    t.integer  "week",                :limit => 10, :null => false
    t.datetime "created_at",          :limit => 29
    t.datetime "updated_at",          :limit => 29
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
    t.datetime "token_expiry",    :limit => 29
    t.boolean  "verified",                      :default => false
    t.boolean  "deleted",                       :default => false
  end

end
