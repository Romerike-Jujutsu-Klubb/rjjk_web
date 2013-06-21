# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130621060851) do

  create_table "martial_arts", :force => true do |t|
    t.string "name",   :limit => 16, :null => false
    t.string "family",               :null => false
  end

  create_table "groups", :force => true do |t|
    t.integer  "martial_art_id",               :null => false
    t.string   "name",                         :null => false
    t.integer  "from_age",                     :null => false
    t.integer  "to_age",                       :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.date     "closed_on"
    t.integer  "monthly_price"
    t.integer  "yearly_price"
    t.string   "contract",       :limit => 16
    t.string   "summary"
    t.text     "description"
    t.boolean  "school_breaks"
    t.index ["martial_art_id"], :name => "fk__groups_martial_art_id"
    t.foreign_key ["martial_art_id"], "martial_arts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_groups_martial_art_id"
  end

  create_table "group_schedules", :force => true do |t|
    t.integer  "group_id",   :null => false
    t.integer  "weekday",    :null => false
    t.time     "start_at",   :null => false
    t.time     "end_at",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.index ["group_id"], :name => "fk__group_schedules_group_id"
    t.foreign_key ["group_id"], "groups", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_group_schedules_group_id"
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

  create_table "images", :force => true do |t|
    t.string   "name",         :limit => 64, :null => false
    t.string   "content_type",               :null => false
    t.binary   "content_data",               :null => false
    t.integer  "user_id",                    :null => false
    t.string   "description",  :limit => 16
    t.text     "story"
    t.boolean  "public"
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "width"
    t.integer  "height"
    t.index ["user_id"], :name => "fk__images_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_images_user_id"
  end

  create_table "members", :force => true do |t|
    t.string   "first_name",           :limit => 100, :default => "", :null => false
    t.string   "last_name",            :limit => 100, :default => "", :null => false
    t.string   "email",                :limit => 128
    t.string   "phone_mobile",         :limit => 32
    t.string   "phone_home",           :limit => 32
    t.string   "phone_work",           :limit => 32
    t.string   "phone_parent",         :limit => 32
    t.date     "birthdate"
    t.boolean  "male",                                                :null => false
    t.date     "joined_on",                                           :null => false
    t.integer  "contract_id"
    t.integer  "cms_contract_id"
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
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "social_sec_no",        :limit => 11
    t.string   "account_no",           :limit => 16
    t.string   "billing_phone_home",   :limit => 32
    t.string   "billing_phone_mobile", :limit => 32
    t.string   "rfid",                 :limit => 25
    t.string   "kid",                  :limit => 64
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.integer  "image_id"
    t.integer  "user_id"
    t.string   "parent_email",         :limit => 32
    t.string   "parent_2_name",        :limit => 64
    t.string   "parent_2_mobile",      :limit => 16
    t.string   "billing_email",        :limit => 32
    t.index ["image_id"], :name => "fk__members_image_id"
    t.index ["user_id"], :name => "fk__members_user_id"
    t.index ["image_id"], :name => "index_members_on_image_id"
    t.index ["user_id"], :name => "index_members_on_user_id"
    t.foreign_key ["image_id"], "images", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_members_image_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_members_user_id"
  end

  create_table "attendances", :force => true do |t|
    t.integer  "member_id",         :null => false
    t.integer  "group_schedule_id", :null => false
    t.integer  "year",              :null => false
    t.integer  "week",              :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.index ["group_schedule_id"], :name => "fk__attendances_group_schedule_id"
    t.index ["member_id"], :name => "fk__attendances_member_id"
    t.index ["member_id", "group_schedule_id", "year", "week"], :name => "ix_attendances_on_member_id_et_group_schedule_id_et_year_et_wee"
    t.foreign_key ["group_schedule_id"], "group_schedules", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_attendances_group_schedule_id"
    t.foreign_key ["member_id"], "members", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_attendances_member_id"
  end

  create_table "birthday_celebrations", :force => true do |t|
    t.date     "held_on",      :null => false
    t.text     "participants", :null => false
    t.integer  "sensor1_id"
    t.integer  "sensor2_id"
    t.integer  "sensor3_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.index ["sensor1_id"], :name => "fk__birthday_celebrations_sensor1_id"
    t.index ["sensor2_id"], :name => "fk__birthday_celebrations_sensor2_id"
    t.index ["sensor3_id"], :name => "fk__birthday_celebrations_sensor3_id"
    t.foreign_key ["sensor1_id"], "members", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_birthday_celebrations_sensor1_id"
    t.foreign_key ["sensor2_id"], "members", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_birthday_celebrations_sensor2_id"
    t.foreign_key ["sensor3_id"], "members", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_birthday_celebrations_sensor3_id"
  end

  create_table "events", :force => true do |t|
    t.string   "name",        :limit => 64, :null => false
    t.datetime "start_at",                  :null => false
    t.datetime "end_at"
    t.text     "description"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.text     "invitees"
  end

  create_table "graduations", :force => true do |t|
    t.date    "held_on",  :null => false
    t.integer "group_id", :null => false
    t.integer "event_id", :null => false
    t.index ["event_id"], :name => "fk__graduations_event_id"
    t.index ["group_id"], :name => "fk__graduations_group_id"
    t.foreign_key ["event_id"], "events", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_graduations_event_id"
    t.foreign_key ["group_id"], "groups", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_graduations_group_id"
  end

  create_table "censors", :force => true do |t|
    t.integer "graduation_id", :null => false
    t.integer "member_id",     :null => false
    t.index ["graduation_id"], :name => "fk__censors_graduation_id"
    t.index ["member_id"], :name => "fk__censors_member_id"
    t.foreign_key ["graduation_id"], "graduations", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_censors_graduation_id"
    t.foreign_key ["member_id"], "members", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_censors_member_id"
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
    t.integer  "contract_id"
    t.integer  "cms_contract_id"
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
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "kid",                  :limit => 64
  end

  create_table "correspondences", :force => true do |t|
    t.datetime "sent_at"
    t.integer  "member_id"
    t.integer  "related_model_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.index ["member_id"], :name => "fk__correspondences_member_id"
    t.foreign_key ["member_id"], "members", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_correspondences_member_id"
  end

  create_table "documents", :force => true do |t|
    t.binary   "content",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ranks", :force => true do |t|
    t.string  "name",            :limit => 16, :null => false
    t.string  "colour",          :limit => 48, :null => false
    t.integer "position",                      :null => false
    t.integer "martial_art_id",                :null => false
    t.integer "standard_months",               :null => false
    t.integer "group_id",                      :null => false
    t.index ["group_id"], :name => "fk__ranks_group_id"
    t.index ["martial_art_id"], :name => "fk__ranks_martial_art_id"
    t.foreign_key ["group_id"], "groups", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_ranks_group_id"
    t.foreign_key ["martial_art_id"], "martial_arts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_ranks_martial_art_id"
  end

  create_table "embus", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "rank_id",     :null => false
    t.text     "description", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.index ["rank_id"], :name => "fk__embus_rank_id"
    t.index ["user_id"], :name => "fk__embus_user_id"
    t.foreign_key ["rank_id"], "ranks", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_embus_rank_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_embus_user_id"
  end

  create_table "embu_images", :force => true do |t|
    t.integer  "embu_id",    :null => false
    t.integer  "image_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.index ["embu_id"], :name => "fk__embu_images_embu_id"
    t.index ["image_id"], :name => "fk__embu_images_image_id"
    t.foreign_key ["embu_id"], "embus", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_embu_images_embu_id"
    t.foreign_key ["image_id"], "images", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_embu_images_image_id"
  end

  create_table "event_invitees", :force => true do |t|
    t.integer  "event_id"
    t.string   "email"
    t.string   "name"
    t.string   "address"
    t.string   "organization"
    t.boolean  "will_attend"
    t.integer  "payed"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "phone"
    t.integer  "user_id"
    t.boolean  "will_work"
    t.string   "comment"
    t.index ["event_id"], :name => "fk__event_invitees_event_id"
    t.index ["user_id"], :name => "fk__event_invitees_user_id"
    t.foreign_key ["event_id"], "events", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_event_invitees_event_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_event_invitees_user_id"
  end

  create_table "event_messages", :force => true do |t|
    t.integer  "event_id"
    t.string   "message_type"
    t.string   "subject"
    t.text     "body"
    t.datetime "ready_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.index ["event_id"], :name => "fk__event_messages_event_id"
    t.foreign_key ["event_id"], "events", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_event_messages_event_id"
  end

  create_table "event_invitee_messages", :force => true do |t|
    t.integer  "event_invitee_id"
    t.string   "message_type"
    t.string   "subject"
    t.text     "body"
    t.datetime "ready_at"
    t.datetime "sent_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "event_message_id"
    t.index ["event_invitee_id"], :name => "fk__event_invitee_messages_event_invitee_id"
    t.index ["event_message_id"], :name => "fk__event_invitee_messages_event_message_id"
    t.foreign_key ["event_invitee_id"], "event_invitees", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_event_invitee_messages_event_invitee_id"
    t.foreign_key ["event_message_id"], "event_messages", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_event_invitee_messages_event_message_id"
  end

  create_table "events_groups", :force => true do |t|
    t.integer "event_id"
    t.integer "group_id"
    t.index ["event_id"], :name => "fk__events_groups_event_id"
    t.index ["group_id"], :name => "fk__events_groups_group_id"
    t.foreign_key ["event_id"], "events", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_events_groups_event_id"
    t.foreign_key ["group_id"], "groups", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_events_groups_group_id"
  end

  create_table "graduates", :force => true do |t|
    t.integer "member_id",       :null => false
    t.integer "graduation_id",   :null => false
    t.boolean "passed",          :null => false
    t.integer "rank_id",         :null => false
    t.boolean "paid_graduation", :null => false
    t.boolean "paid_belt",       :null => false
    t.index ["graduation_id"], :name => "fk__graduates_graduation_id"
    t.index ["member_id"], :name => "fk__graduates_member_id"
    t.index ["rank_id"], :name => "fk__graduates_rank_id"
    t.foreign_key ["graduation_id"], "graduations", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_graduates_graduation_id"
    t.foreign_key ["member_id"], "members", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_graduates_member_id"
    t.foreign_key ["rank_id"], "ranks", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_graduates_rank_id"
  end

  create_table "group_instructors", :force => true do |t|
    t.integer  "member_id"
    t.date     "from"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "group_schedule_id", :null => false
    t.date     "to"
    t.index ["group_schedule_id"], :name => "fk__group_instructors_group_schedule_id"
    t.index ["member_id"], :name => "fk__group_instructors_member_id"
    t.foreign_key ["group_schedule_id"], "group_schedules", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_group_instructors_group_schedule_id"
    t.foreign_key ["member_id"], "members", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_group_instructors_member_id"
  end

  create_table "semesters", :force => true do |t|
    t.date     "start_on",   :null => false
    t.date     "end_on",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "group_semesters", :force => true do |t|
    t.integer  "group_id",      :null => false
    t.integer  "semester_id",   :null => false
    t.date     "first_session"
    t.date     "last_session"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.index ["group_id"], :name => "fk__group_semesters_group_id"
    t.index ["semester_id"], :name => "fk__group_semesters_semester_id"
    t.foreign_key ["group_id"], "groups", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_group_semesters_group_id"
    t.foreign_key ["semester_id"], "semesters", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_group_semesters_semester_id"
  end

  create_table "groups_members", :id => false, :force => true do |t|
    t.integer "group_id",  :null => false
    t.integer "member_id", :null => false
    t.index ["group_id"], :name => "fk__groups_members_group_id"
    t.index ["member_id"], :name => "fk__groups_members_member_id"
    t.index ["group_id", "member_id"], :name => "index_groups_members_on_group_id_and_member_id"
    t.foreign_key ["group_id"], "groups", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_groups_members_group_id"
    t.foreign_key ["member_id"], "members", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_groups_members_member_id"
  end

  create_table "information_pages", :force => true do |t|
    t.integer  "parent_id"
    t.string   "title",      :limit => 32, :null => false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "hidden"
    t.index ["parent_id"], :name => "fk__information_pages_parent_id"
    t.foreign_key ["parent_id"], "information_pages", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_information_pages_parent_id"
  end

  create_table "news_items", :force => true do |t|
    t.string   "title",             :limit => 64, :null => false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.string   "publication_state",               :null => false
    t.datetime "publish_at"
    t.datetime "expire_at"
    t.datetime "mailed_at"
    t.index ["created_by"], :name => "fk__news_items_created_by"
    t.foreign_key ["created_by"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_news_items_created_by"
  end

  create_table "nkf_member_trials", :force => true do |t|
    t.string   "medlems_type",  :limit => 16, :null => false
    t.string   "etternavn",     :limit => 32, :null => false
    t.string   "fornavn",       :limit => 32, :null => false
    t.date     "fodtdato",                    :null => false
    t.integer  "alder",                       :null => false
    t.string   "postnr",        :limit => 4,  :null => false
    t.string   "sted",          :limit => 32, :null => false
    t.string   "adresse",       :limit => 64
    t.string   "epost",         :limit => 64, :null => false
    t.string   "mobil",         :limit => 16
    t.boolean  "res_sms",                     :null => false
    t.date     "reg_dato",                    :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "tid",                         :null => false
    t.string   "epost_faktura", :limit => 64
    t.string   "stilart",       :limit => 64, :null => false
    t.index ["tid"], :name => "index_nkf_member_trials_on_tid"
  end

  create_table "nkf_members", :force => true do |t|
    t.integer  "member_id"
    t.integer  "medlemsnummer"
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
    t.string   "rabatt"
    t.string   "gren_stilart_avd_parti___gren_stilart_avd_parti"
    t.string   "sist_betalt_dato"
    t.string   "betalt_t_o_m__dato"
    t.string   "konkurranseomrade_id"
    t.string   "konkurranseomrade_navn"
    t.string   "klubb_id"
    t.string   "klubb"
    t.integer  "hovedmedlem_id"
    t.string   "hovedmedlem_navn"
    t.string   "innmeldtdato"
    t.string   "innmeldtarsak"
    t.string   "utmeldtdato"
    t.string   "utmeldtarsak"
    t.string   "antall_etiketter_1"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.string   "ventekid",                                        :limit => 20
    t.integer  "kontraktsbelop"
    t.string   "kjonn",                                           :limit => 6,  :null => false
    t.string   "foresatte",                                       :limit => 64
    t.string   "foresatte_epost",                                 :limit => 32
    t.string   "foresatte_mobil",                                 :limit => 16
    t.string   "foresatte_nr_2",                                  :limit => 64
    t.string   "foresatte_nr_2_mobil",                            :limit => 16
    t.index ["member_id"], :name => "fk__nkf_members_member_id"
    t.foreign_key ["member_id"], "members", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_nkf_members_member_id"
  end

  create_table "trial_attendances", :force => true do |t|
    t.integer  "nkf_member_trial_id", :null => false
    t.integer  "group_schedule_id",   :null => false
    t.integer  "year",                :null => false
    t.integer  "week",                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_schedule_id"], :name => "fk__trial_attendances_group_schedule_id"
    t.index ["nkf_member_trial_id"], :name => "fk__trial_attendances_nkf_member_trial_id"
    t.index ["nkf_member_trial_id", "group_schedule_id", "year", "week"], :name => "ix_trial_attendances__nkf_member_trial_group_schedule_year_week"
    t.foreign_key ["group_schedule_id"], "group_schedules", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_trial_attendances_group_schedule_id"
    t.foreign_key ["nkf_member_trial_id"], "nkf_member_trials", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_trial_attendances_nkf_member_trial_id"
  end

  create_table "user_images", :force => true do |t|
    t.integer  "user_id",                  :null => false
    t.integer  "image_id",                 :null => false
    t.string   "rel_type",   :limit => 16, :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.index ["image_id"], :name => "fk__user_images_image_id"
    t.index ["user_id"], :name => "fk__user_images_user_id"
    t.index ["user_id", "image_id", "rel_type"], :name => "index_user_images_on_user_id_and_image_id_and_rel_type"
    t.foreign_key ["image_id"], "images", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_user_images_image_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_user_images_user_id"
  end

end
