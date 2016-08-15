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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160728122913) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "annual_meetings", force: :cascade do |t|
    t.datetime "start_at"
    t.text     "invitation"
    t.datetime "invitation_sent_at"
    t.datetime "public_record_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "martial_arts", force: :cascade do |t|
    t.string "name",   :limit=>16, :null=>false
    t.string "family", :null=>false
  end

  create_table "groups", force: :cascade do |t|
    t.integer  "martial_art_id", :null=>false, :index=>{:name=>"fk__groups_martial_art_id"}, :foreign_key=>{:references=>"martial_arts", :name=>"fk_groups_martial_art_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "name",           :null=>false
    t.integer  "from_age",       :null=>false
    t.integer  "to_age",         :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "closed_on"
    t.integer  "monthly_price"
    t.integer  "yearly_price"
    t.string   "contract",       :limit=>16
    t.string   "summary"
    t.text     "description"
    t.boolean  "school_breaks"
    t.string   "color",          :limit=>16
    t.integer  "target_size"
  end

  create_table "ranks", force: :cascade do |t|
    t.string  "name",            :limit=>16, :null=>false
    t.string  "colour",          :limit=>48, :null=>false
    t.integer "position",        :null=>false
    t.integer "martial_art_id",  :null=>false, :index=>{:name=>"fk__ranks_martial_art_id"}, :foreign_key=>{:references=>"martial_arts", :name=>"fk_ranks_martial_art_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer "standard_months", :null=>false
    t.integer "group_id",        :null=>false, :index=>{:name=>"fk__ranks_group_id"}, :foreign_key=>{:references=>"groups", :name=>"fk_ranks_group_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.text    "description"
    t.string  "decoration",      :limit=>16
  end

  create_table "technique_applications", force: :cascade do |t|
    t.string   "name",       :null=>false
    t.string   "system",     :null=>false
    t.integer  "rank_id",    :index=>{:name=>"fk__technique_applications_rank_id"}, :foreign_key=>{:references=>"ranks", :name=>"fk_technique_applications_rank_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "technique_applications", ["rank_id", "name"], :name=>"index_technique_applications_on_rank_id_and_name", :unique=>true

  create_table "application_steps", force: :cascade do |t|
    t.integer  "technique_application_id", :null=>false, :index=>{:name=>"fk__application_steps_technique_application_id"}, :foreign_key=>{:references=>"technique_applications", :name=>"fk_application_steps_technique_application_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "position",                 :null=>false
    t.text     "description"
    t.string   "image_filename"
    t.string   "image_content_type"
    t.binary   "image_content_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "application_steps", ["technique_application_id", "position"], :name=>"index_application_steps_on_technique_application_id_and_positio"

  create_table "users", force: :cascade do |t|
    t.string   "login",           :limit=>80, :null=>false
    t.string   "salted_password", :limit=>40, :null=>false
    t.string   "email",           :limit=>64, :null=>false
    t.string   "first_name",      :limit=>40
    t.string   "last_name",       :limit=>40
    t.string   "salt",            :limit=>40, :null=>false
    t.string   "role",            :limit=>40
    t.string   "security_token",  :limit=>40
    t.datetime "token_expiry"
    t.boolean  "verified",        :default=>false
    t.boolean  "deleted",         :default=>false
  end

  create_table "images", force: :cascade do |t|
    t.string   "name",         :limit=>64, :null=>false
    t.string   "content_type", :null=>false
    t.binary   "content_data", :null=>false
    t.integer  "user_id",      :null=>false, :index=>{:name=>"fk__images_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_images_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "description",  :limit=>16
    t.text     "story"
    t.boolean  "public"
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "width"
    t.integer  "height"
  end

  create_table "members", force: :cascade do |t|
    t.string   "first_name",           :limit=>100, :default=>"", :null=>false
    t.string   "last_name",            :limit=>100, :default=>"", :null=>false
    t.string   "email",                :limit=>128
    t.string   "phone_mobile",         :limit=>32
    t.string   "phone_home",           :limit=>32
    t.string   "phone_work",           :limit=>32
    t.string   "phone_parent",         :limit=>32
    t.date     "birthdate"
    t.boolean  "male",                 :null=>false
    t.date     "joined_on",            :null=>false
    t.integer  "contract_id"
    t.integer  "cms_contract_id"
    t.date     "left_on"
    t.string   "parent_name",          :limit=>100
    t.string   "address",              :limit=>100, :default=>"", :null=>false
    t.string   "postal_code",          :limit=>4, :null=>false
    t.string   "billing_type",         :limit=>100
    t.string   "billing_name",         :limit=>100
    t.string   "billing_address",      :limit=>100
    t.string   "billing_postal_code",  :limit=>4
    t.boolean  "payment_problem",      :null=>false
    t.string   "comment"
    t.boolean  "instructor",           :null=>false
    t.boolean  "nkf_fee",              :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "social_sec_no",        :limit=>11
    t.string   "account_no",           :limit=>16
    t.string   "billing_phone_home",   :limit=>32
    t.string   "billing_phone_mobile", :limit=>32
    t.string   "rfid",                 :limit=>25
    t.string   "kid",                  :limit=>64
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.integer  "image_id",             :index=>{:name=>"fk__members_image_id"}, :foreign_key=>{:references=>"images", :name=>"fk_members_image_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "user_id",              :index=>{:name=>"fk__members_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_members_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "parent_email",         :limit=>64
    t.string   "parent_2_name",        :limit=>64
    t.string   "parent_2_mobile",      :limit=>16
    t.string   "billing_email",        :limit=>64
  end
  add_index "members", ["image_id"], :name=>"index_members_on_image_id", :unique=>true
  add_index "members", ["user_id"], :name=>"index_members_on_user_id", :unique=>true

  create_table "roles", force: :cascade do |t|
    t.string   "name",               :limit=>32, :null=>false
    t.integer  "years_on_the_board"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appointments", force: :cascade do |t|
    t.integer  "member_id",  :null=>false, :index=>{:name=>"fk__appointments_member_id"}, :foreign_key=>{:references=>"members", :name=>"fk_appointments_member_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "role_id",    :null=>false, :index=>{:name=>"fk__appointments_role_id"}, :foreign_key=>{:references=>"roles", :name=>"fk_appointments_role_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.date     "from",       :null=>false
    t.date     "to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_schedules", force: :cascade do |t|
    t.integer  "group_id",   :null=>false, :index=>{:name=>"fk__group_schedules_group_id"}, :foreign_key=>{:references=>"groups", :name=>"fk_group_schedules_group_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "weekday",    :null=>false
    t.time     "start_at",   :null=>false
    t.time     "end_at",     :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "practices", force: :cascade do |t|
    t.integer  "group_schedule_id", :null=>false, :index=>{:name=>"fk__practices_group_schedule_id"}, :foreign_key=>{:references=>"group_schedules", :name=>"fk_practices_group_schedule_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "year",              :null=>false
    t.integer  "week",              :null=>false
    t.string   "status",            :default=>"X", :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message"
    t.datetime "message_nagged_at"
  end
  add_index "practices", ["group_schedule_id", "year", "week"], :name=>"index_practices_on_group_schedule_id_and_year_and_week", :unique=>true

  create_table "attendances", force: :cascade do |t|
    t.integer  "member_id",            :null=>false, :index=>{:name=>"fk__attendances_member_id"}, :foreign_key=>{:references=>"members", :name=>"fk_attendances_member_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",               :limit=>1, :null=>false
    t.datetime "sent_review_email_at"
    t.integer  "rating"
    t.string   "comment",              :limit=>250
    t.integer  "practice_id",          :null=>false, :index=>{:name=>"fk__attendances_practice_id"}, :foreign_key=>{:references=>"practices", :name=>"fk_attendances_practice_id", :on_update=>:no_action, :on_delete=>:no_action}
  end
  add_index "attendances", ["member_id", "practice_id"], :name=>"index_attendances_on_member_id_and_practice_id", :unique=>true

  create_table "wazas", force: :cascade do |t|
    t.string   "name",        :null=>false, :index=>{:name=>"index_wazas_on_name", :unique=>true}
    t.string   "translation"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "basic_techniques", force: :cascade do |t|
    t.string   "name",        :null=>false, :index=>{:name=>"index_basic_techniques_on_name", :unique=>true}
    t.string   "translation"
    t.integer  "waza_id",     :null=>false, :index=>{:name=>"fk__basic_techniques_waza_id"}, :foreign_key=>{:references=>"wazas", :name=>"fk_basic_techniques_waza_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.text     "description"
    t.integer  "rank_id",     :index=>{:name=>"fk__basic_techniques_rank_id"}, :foreign_key=>{:references=>"ranks", :name=>"fk_basic_techniques_rank_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "basic_technique_links", force: :cascade do |t|
    t.integer  "basic_technique_id", :null=>false, :index=>{:name=>"fk__basic_technique_links_basic_technique_id"}, :foreign_key=>{:references=>"basic_techniques", :name=>"fk_basic_technique_links_basic_technique_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "title",              :limit=>64
    t.string   "url",                :limit=>128, :null=>false
    t.integer  "position",           :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "basic_technique_links", ["basic_technique_id", "position"], :name=>"index_basic_technique_links_on_basic_technique_id_and_position", :unique=>true
  add_index "basic_technique_links", ["basic_technique_id", "url"], :name=>"index_basic_technique_links_on_basic_technique_id_and_url", :unique=>true

  create_table "birthday_celebrations", force: :cascade do |t|
    t.date     "held_on",      :null=>false
    t.text     "participants", :null=>false
    t.integer  "sensor1_id",   :index=>{:name=>"fk__birthday_celebrations_sensor1_id"}, :foreign_key=>{:references=>"members", :name=>"fk_birthday_celebrations_sensor1_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "sensor2_id",   :index=>{:name=>"fk__birthday_celebrations_sensor2_id"}, :foreign_key=>{:references=>"members", :name=>"fk_birthday_celebrations_sensor2_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "sensor3_id",   :index=>{:name=>"fk__birthday_celebrations_sensor3_id"}, :foreign_key=>{:references=>"members", :name=>"fk_birthday_celebrations_sensor3_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "board_meetings", force: :cascade do |t|
    t.datetime "start_at",             :null=>false
    t.string   "minutes_filename",     :limit=>64
    t.string   "minutes_content_type", :limit=>32
    t.binary   "minutes_content_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "graduations", force: :cascade do |t|
    t.date     "held_on",               :null=>false
    t.integer  "group_id",              :null=>false, :index=>{:name=>"fk__graduations_group_id"}, :foreign_key=>{:references=>"groups", :name=>"fk_graduations_group_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "shopping_list_sent_at"
  end

  create_table "censors", force: :cascade do |t|
    t.integer  "graduation_id",      :null=>false, :index=>{:name=>"fk__censors_graduation_id"}, :foreign_key=>{:references=>"graduations", :name=>"fk_censors_graduation_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "member_id",          :null=>false, :index=>{:name=>"fk__censors_member_id"}, :foreign_key=>{:references=>"members", :name=>"fk_censors_member_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.boolean  "examiner"
    t.datetime "requested_at"
    t.datetime "confirmed_at"
    t.datetime "approved_grades_at"
    t.datetime "lock_reminded_at"
    t.datetime "locked_at"
    t.boolean  "declined"
  end
  add_index "censors", ["graduation_id", "member_id"], :name=>"index_censors_on_graduation_id_and_member_id", :unique=>true

  create_table "cms_members", force: :cascade do |t|
    t.string   "first_name",           :limit=>100, :default=>"", :null=>false
    t.string   "last_name",            :limit=>100, :default=>"", :null=>false
    t.string   "email",                :limit=>128
    t.string   "phone_mobile",         :limit=>32
    t.string   "phone_home",           :limit=>32
    t.string   "phone_work",           :limit=>32
    t.string   "phone_parent",         :limit=>32
    t.date     "birthdate"
    t.boolean  "male",                 :null=>false
    t.date     "joined_on"
    t.integer  "contract_id"
    t.integer  "cms_contract_id"
    t.date     "left_on"
    t.string   "parent_name",          :limit=>100
    t.string   "address",              :limit=>100, :default=>"", :null=>false
    t.string   "postal_code",          :limit=>4, :null=>false
    t.string   "billing_type",         :limit=>100
    t.string   "billing_name",         :limit=>100
    t.string   "billing_address",      :limit=>100
    t.string   "billing_postal_code",  :limit=>4
    t.boolean  "payment_problem",      :null=>false
    t.string   "comment"
    t.boolean  "instructor",           :null=>false
    t.boolean  "nkf_fee",              :null=>false
    t.string   "social_sec_no",        :limit=>11
    t.string   "account_no",           :limit=>16
    t.string   "billing_phone_home",   :limit=>32
    t.string   "billing_phone_mobile", :limit=>32
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kid",                  :limit=>64
  end

  create_table "correspondences", force: :cascade do |t|
    t.datetime "sent_at"
    t.integer  "member_id",        :index=>{:name=>"fk__correspondences_member_id"}, :foreign_key=>{:references=>"members", :name=>"fk_correspondences_member_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "related_model_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", force: :cascade do |t|
    t.binary   "content",    :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "elections", force: :cascade do |t|
    t.integer  "annual_meeting_id", :null=>false, :index=>{:name=>"fk__elections_annual_meeting_id"}, :foreign_key=>{:references=>"annual_meetings", :name=>"fk_elections_annual_meeting_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "member_id",         :null=>false, :index=>{:name=>"fk__elections_member_id"}, :foreign_key=>{:references=>"members", :name=>"fk_elections_member_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "role_id",           :null=>false, :index=>{:name=>"fk__elections_role_id"}, :foreign_key=>{:references=>"roles", :name=>"fk_elections_role_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "years",             :null=>false
    t.date     "resigned_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "guardian"
  end

  create_table "embus", force: :cascade do |t|
    t.integer  "user_id",     :null=>false, :index=>{:name=>"fk__embus_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_embus_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "rank_id",     :null=>false, :index=>{:name=>"fk__embus_rank_id"}, :foreign_key=>{:references=>"ranks", :name=>"fk_embus_rank_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.text     "description", :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embu_images", force: :cascade do |t|
    t.integer  "embu_id",    :null=>false, :index=>{:name=>"fk__embu_images_embu_id"}, :foreign_key=>{:references=>"embus", :name=>"fk_embu_images_embu_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "image_id",   :null=>false, :index=>{:name=>"fk__embu_images_image_id"}, :foreign_key=>{:references=>"images", :name=>"fk_embu_images_image_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: :cascade do |t|
    t.string   "name",        :limit=>64, :null=>false
    t.datetime "start_at",    :null=>false
    t.datetime "end_at"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "invitees"
  end

  create_table "event_invitees", force: :cascade do |t|
    t.integer  "event_id",     :index=>{:name=>"fk__event_invitees_event_id"}, :foreign_key=>{:references=>"events", :name=>"fk_event_invitees_event_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "email"
    t.string   "name"
    t.string   "address"
    t.string   "organization"
    t.boolean  "will_attend"
    t.integer  "payed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone"
    t.integer  "user_id",      :index=>{:name=>"fk__event_invitees_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_event_invitees_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.boolean  "will_work"
    t.string   "comment"
  end

  create_table "event_messages", force: :cascade do |t|
    t.integer  "event_id",     :index=>{:name=>"fk__event_messages_event_id"}, :foreign_key=>{:references=>"events", :name=>"fk_event_messages_event_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "message_type"
    t.string   "subject"
    t.text     "body"
    t.datetime "ready_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_invitee_messages", force: :cascade do |t|
    t.integer  "event_invitee_id", :index=>{:name=>"fk__event_invitee_messages_event_invitee_id"}, :foreign_key=>{:references=>"event_invitees", :name=>"fk_event_invitee_messages_event_invitee_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "message_type"
    t.string   "subject"
    t.text     "body"
    t.datetime "ready_at"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_message_id", :index=>{:name=>"fk__event_invitee_messages_event_message_id"}, :foreign_key=>{:references=>"event_messages", :name=>"fk_event_invitee_messages_event_message_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_table "events_groups", force: :cascade do |t|
    t.integer "event_id", :index=>{:name=>"fk__events_groups_event_id"}, :foreign_key=>{:references=>"events", :name=>"fk_events_groups_event_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer "group_id", :index=>{:name=>"fk__events_groups_group_id"}, :foreign_key=>{:references=>"groups", :name=>"fk_events_groups_group_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_table "graduates", force: :cascade do |t|
    t.integer  "member_id",          :null=>false, :index=>{:name=>"fk__graduates_member_id"}, :foreign_key=>{:references=>"members", :name=>"fk_graduates_member_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "graduation_id",      :null=>false, :index=>{:name=>"fk__graduates_graduation_id"}, :foreign_key=>{:references=>"graduations", :name=>"fk_graduates_graduation_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.boolean  "passed"
    t.integer  "rank_id",            :null=>false, :index=>{:name=>"fk__graduates_rank_id"}, :foreign_key=>{:references=>"ranks", :name=>"fk_graduates_rank_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.boolean  "paid_graduation",    :null=>false
    t.boolean  "paid_belt",          :null=>false
    t.datetime "invitation_sent_at"
    t.datetime "confirmed_at"
    t.boolean  "declined"
  end

  create_table "semesters", force: :cascade do |t|
    t.date     "start_on",   :null=>false
    t.date     "end_on",     :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_semesters", force: :cascade do |t|
    t.integer  "group_id",            :null=>false, :index=>{:name=>"fk__group_semesters_group_id"}, :foreign_key=>{:references=>"groups", :name=>"fk_group_semesters_group_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "semester_id",         :null=>false, :index=>{:name=>"fk__group_semesters_semester_id"}, :foreign_key=>{:references=>"semesters", :name=>"fk_group_semesters_semester_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.date     "first_session"
    t.date     "last_session"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chief_instructor_id", :index=>{:name=>"fk__group_semesters_chief_instructor_id"}, :foreign_key=>{:references=>"members", :name=>"fk_group_semesters_chief_instructor_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.text     "summary"
  end

  create_table "group_instructors", force: :cascade do |t|
    t.integer  "member_id",         :index=>{:name=>"fk__group_instructors_member_id"}, :foreign_key=>{:references=>"members", :name=>"fk_group_instructors_member_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_schedule_id", :null=>false, :index=>{:name=>"fk__group_instructors_group_schedule_id"}, :foreign_key=>{:references=>"group_schedules", :name=>"fk_group_instructors_group_schedule_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "group_semester_id", :null=>false, :index=>{:name=>"fk__group_instructors_group_semester_id"}, :foreign_key=>{:references=>"group_semesters", :name=>"fk_group_instructors_group_semester_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.boolean  "assistant",         :default=>false, :null=>false
  end

  create_table "groups_members", id: false, force: :cascade do |t|
    t.integer "group_id",  :null=>false, :index=>{:name=>"fk__groups_members_group_id"}, :foreign_key=>{:references=>"groups", :name=>"fk_groups_members_group_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer "member_id", :null=>false, :index=>{:name=>"fk__groups_members_member_id"}, :foreign_key=>{:references=>"members", :name=>"fk_groups_members_member_id", :on_update=>:no_action, :on_delete=>:no_action}
  end
  add_index "groups_members", ["group_id", "member_id"], :name=>"index_groups_members_on_group_id_and_member_id", :unique=>true

  create_table "information_pages", force: :cascade do |t|
    t.integer  "parent_id",  :index=>{:name=>"fk__information_pages_parent_id"}, :foreign_key=>{:references=>"information_pages", :name=>"fk_information_pages_parent_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "title",      :limit=>32, :null=>false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "hidden"
    t.datetime "revised_at"
    t.datetime "mailed_at"
  end

  create_table "instructor_meetings", force: :cascade do |t|
    t.datetime "start_at",   :null=>false
    t.time     "end_at",     :null=>false
    t.string   "title",      :limit=>254
    t.text     "agenda"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "news_items", force: :cascade do |t|
    t.string   "title",             :limit=>64, :null=>false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",        :index=>{:name=>"fk__news_items_created_by"}, :foreign_key=>{:references=>"users", :name=>"fk_news_items_created_by", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "publication_state", :null=>false
    t.datetime "publish_at"
    t.datetime "expire_at"
    t.datetime "mailed_at"
    t.text     "summary"
  end

  create_table "nkf_member_trials", force: :cascade do |t|
    t.string   "medlems_type",  :limit=>16, :null=>false
    t.string   "etternavn",     :limit=>32, :null=>false
    t.string   "fornavn",       :limit=>32, :null=>false
    t.date     "fodtdato",      :null=>false
    t.integer  "alder",         :null=>false
    t.string   "postnr",        :limit=>4, :null=>false
    t.string   "sted",          :limit=>32, :null=>false
    t.string   "adresse",       :limit=>64
    t.string   "epost",         :limit=>64, :null=>false
    t.string   "mobil",         :limit=>16
    t.boolean  "res_sms",       :null=>false
    t.date     "reg_dato",      :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tid",           :null=>false, :index=>{:name=>"index_nkf_member_trials_on_tid", :unique=>true}
    t.string   "epost_faktura", :limit=>64
    t.string   "stilart",       :limit=>64, :null=>false
  end

  create_table "nkf_members", force: :cascade do |t|
    t.integer  "member_id",                                       :index=>{:name=>"fk__nkf_members_member_id"}, :foreign_key=>{:references=>"members", :name=>"fk_nkf_members_member_id", :on_update=>:no_action, :on_delete=>:no_action}
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ventekid",                                        :limit=>20
    t.integer  "kontraktsbelop"
    t.string   "kjonn",                                           :limit=>6, :null=>false
    t.string   "foresatte",                                       :limit=>64
    t.string   "foresatte_epost",                                 :limit=>32
    t.string   "foresatte_mobil",                                 :limit=>16
    t.string   "foresatte_nr_2",                                  :limit=>64
    t.string   "foresatte_nr_2_mobil",                            :limit=>16
  end

  create_table "page_aliases", force: :cascade do |t|
    t.string   "old_path",   :index=>{:name=>"index_page_aliases_on_old_path", :unique=>true}
    t.string   "new_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public_records", force: :cascade do |t|
    t.string   "contact",       :null=>false
    t.string   "chairman",      :null=>false
    t.string   "board_members", :null=>false
    t.string   "deputies",      :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "raw_incoming_emails", force: :cascade do |t|
    t.binary   "content",      :null=>false
    t.datetime "processed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "postponed_at"
  end

  create_table "signatures", force: :cascade do |t|
    t.integer  "member_id",    :null=>false, :index=>{:name=>"fk__signatures_member_id"}, :foreign_key=>{:references=>"members", :name=>"fk_signatures_member_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "name",         :null=>false
    t.string   "content_type", :null=>false
    t.binary   "image",        :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_answer_translations", force: :cascade do |t|
    t.string   "answer",            :limit=>254, :null=>false
    t.string   "normalized_answer", :limit=>254, :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", force: :cascade do |t|
    t.string   "category",     :limit=>8
    t.integer  "days_active"
    t.integer  "days_passive"
    t.integer  "days_left"
    t.integer  "group_id",     :index=>{:name=>"fk__surveys_group_id"}, :foreign_key=>{:references=>"groups", :name=>"fk_surveys_group_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.boolean  "ready"
    t.string   "title",        :limit=>64, :null=>false
    t.integer  "position",     :null=>false
    t.datetime "expires_at"
    t.text     "header"
    t.text     "footer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_questions", force: :cascade do |t|
    t.integer  "survey_id",       :null=>false, :index=>{:name=>"fk__survey_questions_survey_id"}, :foreign_key=>{:references=>"surveys", :name=>"fk_survey_questions_survey_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "position",        :null=>false
    t.string   "title",           :limit=>254, :null=>false
    t.string   "choices",         :limit=>254
    t.boolean  "select_multiple"
    t.boolean  "free_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_requests", force: :cascade do |t|
    t.integer  "survey_id",    :null=>false, :index=>{:name=>"fk__survey_requests_survey_id"}, :foreign_key=>{:references=>"surveys", :name=>"fk_survey_requests_survey_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "member_id",    :null=>false, :index=>{:name=>"fk__survey_requests_member_id"}, :foreign_key=>{:references=>"members", :name=>"fk_survey_requests_member_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.text     "comment"
    t.datetime "sent_at"
    t.datetime "reminded_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "survey_requests", ["survey_id", "member_id"], :name=>"index_survey_requests_on_survey_id_and_member_id", :unique=>true

  create_table "survey_answers", force: :cascade do |t|
    t.integer  "survey_request_id",  :null=>false, :index=>{:name=>"fk__survey_answers_survey_request_id"}, :foreign_key=>{:references=>"survey_requests", :name=>"fk_survey_answers_survey_request_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "survey_question_id", :null=>false, :index=>{:name=>"fk__survey_answers_survey_question_id"}, :foreign_key=>{:references=>"survey_questions", :name=>"fk_survey_answers_survey_question_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "answer",             :limit=>254, :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trial_attendances", force: :cascade do |t|
    t.integer  "nkf_member_trial_id", :null=>false, :index=>{:name=>"fk__trial_attendances_nkf_member_trial_id"}, :foreign_key=>{:references=>"nkf_member_trials", :name=>"fk_trial_attendances_nkf_member_trial_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "practice_id",         :null=>false, :index=>{:name=>"fk__trial_attendances_practice_id"}, :foreign_key=>{:references=>"practices", :name=>"fk_trial_attendances_practice_id", :on_update=>:no_action, :on_delete=>:no_action}
  end
  add_index "trial_attendances", ["nkf_member_trial_id", "practice_id"], :name=>"index_trial_attendances_on_nkf_member_trial_id_and_practice_id", :unique=>true

  create_table "user_images", force: :cascade do |t|
    t.integer  "user_id",    :null=>false, :index=>{:name=>"fk__user_images_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_user_images_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "image_id",   :null=>false, :index=>{:name=>"fk__user_images_image_id"}, :foreign_key=>{:references=>"images", :name=>"fk_user_images_image_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "rel_type",   :limit=>16, :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "user_images", ["user_id", "image_id", "rel_type"], :name=>"index_user_images_on_user_id_and_image_id_and_rel_type", :unique=>true

  create_table "user_messages", force: :cascade do |t|
    t.integer  "user_id",           :null=>false, :index=>{:name=>"fk__user_messages_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_user_messages_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "tag",               :limit=>64
    t.string   "key",               :limit=>64, :null=>false
    t.string   "from",              :null=>false
    t.string   "subject",           :limit=>160, :null=>false
    t.datetime "message_timestamp"
    t.string   "email_url",         :limit=>254
    t.string   "user_email",        :limit=>128
    t.string   "title",             :limit=>64
    t.text     "html_body"
    t.text     "plain_body"
    t.datetime "sent_at"
    t.datetime "read_at"
    t.datetime "created_at",        :null=>false
    t.datetime "updated_at",        :null=>false
  end

end
