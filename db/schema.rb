# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_25_100124) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'active_storage_attachments', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'record_type', null: false
    t.bigint 'record_id', null: false
    t.bigint 'blob_id', null: false
    t.datetime 'created_at', null: false
    t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
    t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness', unique: true
  end

  create_table 'active_storage_blobs', force: :cascade do |t|
    t.string 'key', null: false
    t.string 'filename', null: false
    t.string 'content_type'
    t.text 'metadata'
    t.bigint 'byte_size', null: false
    t.string 'checksum', null: false
    t.datetime 'created_at', null: false
    t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
  end

  create_table 'active_storage_data', force: :cascade do |t|
    t.string 'key', null: false
    t.binary 'io', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['key'], name: 'index_active_storage_data_on_key'
  end

  create_table 'application_image_sequences', force: :cascade do |t|
    t.bigint 'technique_application_id', null: false
    t.integer 'position', null: false
    t.string 'title'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[technique_application_id position], name: 'idx_app_image_seqs_on_technique_application_id_and_position', unique: true
    t.index ['technique_application_id'], name: 'index_application_image_sequences_on_technique_application_id'
  end

  create_table 'application_steps', force: :cascade do |t|
    t.integer 'position', null: false
    t.text 'description'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'image_id'
    t.bigint 'application_image_sequence_id'
    t.index %w[application_image_sequence_id position], name: 'idx_application_steps__application_image_sequence_id__position', unique: true
    t.index ['application_image_sequence_id'], name: 'index_application_steps_on_application_image_sequence_id'
  end

  create_table 'application_videos', force: :cascade do |t|
    t.bigint 'technique_application_id'
    t.bigint 'image_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['image_id'], name: 'index_application_videos_on_image_id'
    t.index %w[technique_application_id image_id], name: 'idx_application_videos_on_technique_application_id_and_image_id', unique: true
    t.index ['technique_application_id'], name: 'index_application_videos_on_technique_application_id'
  end

  create_table 'appointments', force: :cascade do |t|
    t.integer 'member_id', null: false
    t.integer 'role_id', null: false
    t.date 'from', null: false
    t.date 'to'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['member_id'], name: 'fk__appointments_member_id'
    t.index ['role_id'], name: 'fk__appointments_role_id'
  end

  create_table 'attendance_webpushes', force: :cascade do |t|
    t.bigint 'member_id', null: false
    t.string 'endpoint', null: false
    t.string 'p256dh', null: false
    t.string 'auth', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['member_id'], name: 'index_attendance_webpushes_on_member_id'
  end

  create_table 'attendances', force: :cascade do |t|
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'status', limit: 1, null: false
    t.datetime 'sent_review_email_at'
    t.integer 'rating'
    t.string 'comment', limit: 250
    t.integer 'practice_id', null: false
    t.datetime 'rated_at'
    t.bigint 'user_id', null: false
    t.index ['practice_id'], name: 'fk__attendances_practice_id'
    t.index %w[user_id practice_id], name: 'index_attendances_on_user_id_and_practice_id', unique: true
    t.index ['user_id'], name: 'index_attendances_on_user_id'
  end

  create_table 'basic_techniques', force: :cascade do |t|
    t.string 'name', limit: 255, null: false
    t.string 'translation', limit: 255
    t.integer 'waza_id', null: false
    t.text 'description'
    t.integer 'rank_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['rank_id'], name: 'fk__basic_techniques_rank_id'
    t.index ['waza_id'], name: 'fk__basic_techniques_waza_id'
  end

  create_table 'birthday_celebrations', force: :cascade do |t|
    t.date 'held_on', null: false
    t.text 'participants', null: false
    t.integer 'sensor1_id'
    t.integer 'sensor2_id'
    t.integer 'sensor3_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'board_meetings', force: :cascade do |t|
    t.datetime 'start_at', null: false
    t.string 'minutes_filename', limit: 64
    t.string 'minutes_content_type', limit: 32
    t.binary 'minutes_content_data'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'card_keys', force: :cascade do |t|
    t.string 'label'
    t.bigint 'user_id'
    t.boolean 'office_key'
    t.text 'comment'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['label'], name: 'index_card_keys_on_label', unique: true
    t.index ['user_id'], name: 'index_card_keys_on_user_id'
  end

  create_table 'censors', force: :cascade do |t|
    t.integer 'graduation_id', null: false
    t.integer 'member_id', null: false
    t.boolean 'examiner', null: false
    t.datetime 'requested_at'
    t.datetime 'confirmed_at'
    t.datetime 'approved_grades_at'
    t.datetime 'lock_reminded_at'
    t.datetime 'locked_at'
    t.boolean 'declined'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'approval_requested_at'
    t.index %w[graduation_id member_id], name: 'index_censors_on_graduation_id_and_member_id', unique: true
  end

  create_table 'correspondences', force: :cascade do |t|
    t.datetime 'sent_at'
    t.integer 'member_id'
    t.integer 'related_model_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'curriculum_groups', force: :cascade do |t|
    t.string 'name', null: false
    t.bigint 'martial_art_id', null: false
    t.integer 'position', null: false
    t.integer 'from_age', null: false
    t.integer 'to_age', null: false
    t.string 'color'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['martial_art_id'], name: 'index_curriculum_groups_on_martial_art_id'
  end

  create_table 'documents', force: :cascade do |t|
    t.binary 'content', null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'elections', force: :cascade do |t|
    t.integer 'annual_meeting_id', null: false
    t.integer 'member_id', null: false
    t.integer 'role_id', null: false
    t.integer 'years', null: false
    t.date 'resigned_on'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['annual_meeting_id'], name: 'fk__elections_annual_meeting_id'
    t.index ['member_id'], name: 'fk__elections_member_id'
    t.index ['role_id'], name: 'fk__elections_role_id'
  end

  create_table 'embu_images', force: :cascade do |t|
    t.integer 'embu_id', null: false
    t.integer 'image_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'embu_part_videos', force: :cascade do |t|
    t.bigint 'embu_part_id', null: false
    t.bigint 'image_id', null: false
    t.text 'comment'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['embu_part_id'], name: 'index_embu_part_videos_on_embu_part_id'
    t.index ['image_id'], name: 'index_embu_part_videos_on_image_id'
  end

  create_table 'embu_parts', force: :cascade do |t|
    t.bigint 'embu_id', null: false
    t.integer 'position', null: false
    t.text 'description'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['embu_id'], name: 'index_embu_parts_on_embu_id'
  end

  create_table 'embus', force: :cascade do |t|
    t.integer 'user_id', null: false
    t.integer 'rank_id', null: false
    t.text 'description', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'event_groups', force: :cascade do |t|
    t.integer 'event_id', null: false
    t.integer 'group_id', null: false
  end

  create_table 'event_invitee_messages', force: :cascade do |t|
    t.integer 'event_invitee_id'
    t.string 'message_type', limit: 255
    t.string 'subject', limit: 255
    t.text 'body'
    t.datetime 'ready_at'
    t.datetime 'sent_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'event_message_id'
  end

  create_table 'event_invitees', force: :cascade do |t|
    t.integer 'event_id', null: false
    t.string 'organization', limit: 255
    t.boolean 'will_attend'
    t.integer 'payed'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'user_id', null: false
    t.boolean 'will_work'
    t.string 'comment', limit: 255
  end

  create_table 'event_messages', force: :cascade do |t|
    t.integer 'event_id'
    t.string 'message_type', limit: 255
    t.string 'subject', limit: 255
    t.text 'body'
    t.datetime 'ready_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'events', force: :cascade do |t|
    t.string 'name', limit: 64, null: false
    t.datetime 'start_at', null: false
    t.datetime 'end_at'
    t.text 'description'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'name_en', limit: 80
    t.text 'description_en'
    t.string 'type'
    t.string 'registration_url', limit: 128
  end

  create_table 'front_page_sections', force: :cascade do |t|
    t.integer 'position', null: false
    t.string 'title'
    t.string 'subtitle'
    t.bigint 'image_id'
    t.string 'button_text'
    t.bigint 'information_page_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['image_id'], name: 'index_front_page_sections_on_image_id'
    t.index ['information_page_id'], name: 'index_front_page_sections_on_information_page_id'
  end

  create_table 'graduates', force: :cascade do |t|
    t.integer 'member_id', null: false
    t.integer 'graduation_id', null: false
    t.boolean 'passed'
    t.integer 'rank_id', null: false
    t.boolean 'paid_graduation', null: false
    t.boolean 'paid_belt', null: false
    t.datetime 'invitation_sent_at'
    t.datetime 'confirmed_at'
    t.boolean 'declined'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'gratz_sent_at'
  end

  create_table 'graduations', force: :cascade do |t|
    t.date 'held_on', null: false
    t.integer 'group_id', null: false
    t.datetime 'shopping_list_sent_at'
    t.boolean 'group_notification', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'date_info_sent_at'
    t.datetime 'notified_missing_censors_at'
    t.date 'date_info_sent_for'
  end

  create_table 'group_instructors', force: :cascade do |t|
    t.integer 'member_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'group_schedule_id', null: false
    t.integer 'group_semester_id', null: false
    t.boolean 'assistant', default: false, null: false
    t.index ['group_semester_id'], name: 'fk__group_instructors_group_semester_id'
  end

  create_table 'group_memberships', force: :cascade do |t|
    t.integer 'group_id', null: false
    t.bigint 'user_id', null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index %w[group_id user_id], name: 'index_group_memberships_on_group_id_and_user_id', unique: true
    t.index ['user_id'], name: 'index_group_memberships_on_user_id'
  end

  create_table 'group_schedules', force: :cascade do |t|
    t.integer 'group_id', null: false
    t.integer 'weekday', null: false
    t.time 'start_at', null: false
    t.time 'end_at', null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'group_semesters', force: :cascade do |t|
    t.integer 'group_id', null: false
    t.integer 'semester_id', null: false
    t.date 'first_session'
    t.date 'last_session'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'chief_instructor_id'
    t.text 'summary'
    t.index ['chief_instructor_id'], name: 'fk__group_semesters_chief_instructor_id'
    t.index ['group_id'], name: 'fk__group_semesters_group_id'
    t.index ['semester_id'], name: 'fk__group_semesters_semester_id'
  end

  create_table 'groups', force: :cascade do |t|
    t.string 'name', limit: 255, null: false
    t.integer 'from_age', null: false
    t.integer 'to_age', null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.date 'closed_on'
    t.integer 'monthly_fee'
    t.integer 'yearly_fee'
    t.string 'contract', limit: 32
    t.string 'summary', limit: 255
    t.text 'description'
    t.boolean 'school_breaks'
    t.string 'color', limit: 16
    t.integer 'target_size'
    t.boolean 'planning'
    t.bigint 'curriculum_group_id'
    t.index ['curriculum_group_id'], name: 'index_groups_on_curriculum_group_id'
  end

  create_table 'images', force: :cascade do |t|
    t.string 'name', limit: 64, null: false
    t.string 'content_type', limit: 255, null: false
    t.binary 'content_data'
    t.integer 'user_id', null: false
    t.string 'description', limit: 16
    t.text 'story'
    t.boolean 'public'
    t.boolean 'approved'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'width'
    t.integer 'height'
    t.string 'google_drive_reference', limit: 33
    t.string 'md5_checksum', limit: 32, null: false
    t.string 'cloudinary_identifier'
    t.datetime 'cloudinary_transformed_at'
    t.integer 'content_length', null: false
    t.index ['md5_checksum'], name: 'index_images_on_md5_checksum', unique: true
  end

  create_table 'information_pages', force: :cascade do |t|
    t.integer 'parent_id'
    t.string 'title', limit: 32, null: false
    t.text 'body'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'position'
    t.boolean 'hidden'
    t.datetime 'revised_at'
    t.datetime 'mailed_at'
    t.boolean 'public', null: false
    t.string 'icon_class'
  end

  create_table 'martial_arts', force: :cascade do |t|
    t.string 'name', limit: 32, null: false
    t.string 'family', limit: 16, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'original_martial_art_id'
    t.index ['name'], name: 'index_martial_arts_on_name', unique: true
    t.index ['original_martial_art_id'], name: 'index_martial_arts_on_original_martial_art_id'
  end

  create_table 'members', force: :cascade do |t|
    t.string 'phone_home', limit: 32
    t.string 'phone_work', limit: 32
    t.date 'joined_on', null: false
    t.date 'left_on'
    t.string 'billing_type', limit: 100
    t.string 'comment', limit: 255
    t.boolean 'instructor', null: false
    t.boolean 'nkf_fee', null: false
    t.string 'social_sec_no', limit: 11
    t.string 'account_no', limit: 16
    t.string 'billing_phone_home', limit: 32
    t.string 'kid', limit: 64
    t.integer 'user_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.date 'passive_on'
    t.datetime 'honorary_on'
    t.integer 'discount_override'
  end

  create_table 'news_item_likes', force: :cascade do |t|
    t.integer 'news_item_id', null: false
    t.integer 'user_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['news_item_id'], name: 'fk__news_item_likes_news_item_id'
    t.index ['user_id'], name: 'fk__news_item_likes_user_id'
  end

  create_table 'news_items', force: :cascade do |t|
    t.string 'title', limit: 64, null: false
    t.text 'body'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'created_by', null: false
    t.string 'publication_state', limit: 255, null: false
    t.datetime 'publish_at'
    t.datetime 'expire_at'
    t.datetime 'mailed_at'
    t.text 'summary'
    t.boolean 'user_selection'
  end

  create_table 'nkf_member_trials', force: :cascade do |t|
    t.string 'etternavn', limit: 32, null: false
    t.string 'fornavn', limit: 32, null: false
    t.date 'fodselsdato', null: false
    t.string 'postnr', limit: 4, null: false
    t.string 'adresse_2', limit: 64
    t.string 'epost', limit: 64, null: false
    t.string 'mobil', limit: 16
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'tid', null: false
    t.string 'epost_faktura', limit: 64
    t.string 'gren_stilart_avd_parti___gren_stilart_avd_parti', limit: 64, null: false
    t.string 'kjonn', null: false
    t.string 'foresatte', limit: 64
    t.string 'foresatte_epost', limit: 64
    t.string 'foresatte_mobil', limit: 25
    t.string 'foresatte_nr_2', limit: 64
    t.string 'foresatte_nr_2_mobil', limit: 25
    t.integer 'hoyde', limit: 2
    t.string 'kont_sats'
    t.string 'kontraktsbelop'
    t.string 'kontraktstype'
    t.string 'medlemskategori_navn'
    t.string 'rabatt'
    t.string 'telefon', limit: 25
    t.string 'telefon_arbeid', limit: 25
    t.date 'reg_dato', null: false
    t.index ['tid'], name: 'index_nkf_member_trials_on_tid', unique: true
  end

  create_table 'nkf_members', force: :cascade do |t|
    t.integer 'member_id'
    t.integer 'medlemsnummer'
    t.string 'etternavn', limit: 255
    t.string 'fornavn', limit: 255
    t.string 'adresse_1', limit: 255
    t.string 'adresse_2', limit: 255
    t.string 'adresse_3', limit: 255
    t.string 'postnr', limit: 255
    t.string 'sted', limit: 255
    t.string 'fodselsdato', limit: 255
    t.string 'telefon', limit: 255
    t.string 'telefon_arbeid', limit: 255
    t.string 'mobil', limit: 255
    t.string 'epost', limit: 255
    t.string 'epost_faktura', limit: 255
    t.string 'yrke', limit: 255
    t.string 'medlemsstatus', limit: 255
    t.string 'medlemskategori', limit: 255
    t.string 'medlemskategori_navn', limit: 255
    t.string 'kont_sats', limit: 255
    t.string 'kont_belop', limit: 255
    t.string 'kontraktstype', limit: 255
    t.string 'kontraktsbelop', limit: 255
    t.string 'rabatt', limit: 255
    t.string 'gren_stilart_avd_parti___gren_stilart_avd_parti', limit: 255
    t.string 'sist_betalt_dato', limit: 255
    t.string 'betalt_t_o_m__dato', limit: 255
    t.string 'konkurranseomrade_id', limit: 255
    t.string 'konkurranseomrade_navn', limit: 255
    t.string 'klubb_id', limit: 255
    t.string 'klubb', limit: 255
    t.integer 'hovedmedlem_id'
    t.string 'hovedmedlem_navn', limit: 255
    t.string 'innmeldtdato', limit: 255
    t.string 'innmeldtarsak', limit: 255
    t.string 'utmeldtdato', limit: 255
    t.string 'utmeldtarsak', limit: 255
    t.string 'antall_etiketter_1', limit: 255
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'ventekid', limit: 20
    t.string 'kjonn', limit: 6, null: false
    t.string 'foresatte', limit: 64
    t.string 'foresatte_epost', limit: 64
    t.string 'foresatte_mobil', limit: 255
    t.string 'foresatte_nr_2', limit: 64
    t.string 'foresatte_nr_2_mobil', limit: 255
    t.integer 'hoyde', limit: 2
  end

  create_table 'page_aliases', force: :cascade do |t|
    t.string 'old_path', limit: 255
    t.string 'new_path', limit: 255
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['old_path'], name: 'index_page_aliases_on_old_path', unique: true
  end

  create_table 'practices', force: :cascade do |t|
    t.integer 'group_schedule_id', null: false
    t.integer 'year', null: false
    t.integer 'week', null: false
    t.string 'status', limit: 255, default: 'X', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'message', limit: 255
    t.datetime 'message_nagged_at'
    t.index %w[group_schedule_id year week], name: 'index_practices_on_group_schedule_id_and_year_and_week', unique: true
    t.index ['group_schedule_id'], name: 'fk__practices_group_schedule_id'
  end

  create_table 'price_age_groups', force: :cascade do |t|
    t.string 'name', null: false
    t.integer 'from_age', null: false
    t.integer 'to_age', null: false
    t.integer 'yearly_fee', null: false
    t.integer 'monthly_fee', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['from_age'], name: 'index_price_age_groups_on_from_age', unique: true
    t.index ['name'], name: 'index_price_age_groups_on_name', unique: true
    t.index ['to_age'], name: 'index_price_age_groups_on_to_age', unique: true
  end

  create_table 'public_records', force: :cascade do |t|
    t.string 'contact', limit: 255, null: false
    t.string 'chairman', limit: 255, null: false
    t.string 'board_members', limit: 255, null: false
    t.string 'deputies', limit: 255, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'rank_articles', force: :cascade do |t|
    t.integer 'position', null: false
    t.bigint 'rank_id', null: false
    t.bigint 'information_page_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['information_page_id'], name: 'index_rank_articles_on_information_page_id'
    t.index %w[rank_id information_page_id], name: 'index_rank_articles_on_rank_id_and_information_page_id', unique: true
    t.index %w[rank_id position], name: 'index_rank_articles_on_rank_id_and_position', unique: true
    t.index ['rank_id'], name: 'index_rank_articles_on_rank_id'
  end

  create_table 'ranks', force: :cascade do |t|
    t.string 'name', limit: 16, null: false
    t.string 'colour', limit: 48, null: false
    t.integer 'position', null: false
    t.integer 'standard_months', null: false
    t.text 'description'
    t.string 'decoration', limit: 16
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'css_color', limit: 24
    t.boolean 'embroydery'
    t.bigint 'curriculum_group_id', null: false
    t.index ['curriculum_group_id'], name: 'index_ranks_on_curriculum_group_id'
  end

  create_table 'roles', force: :cascade do |t|
    t.string 'name', limit: 32, null: false
    t.integer 'years_on_the_board'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'position'
  end

  create_table 'semesters', force: :cascade do |t|
    t.date 'start_on', null: false
    t.date 'end_on', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'signatures', force: :cascade do |t|
    t.string 'name', limit: 255, null: false
    t.string 'content_type', limit: 255, null: false
    t.binary 'image', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'user_id'
    t.index ['user_id'], name: 'index_signatures_on_user_id'
  end

  create_table 'signups', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'nkf_member_trial_id'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.datetime 'deleted_at'
    t.index ['deleted_at'], name: 'index_signups_on_deleted_at'
    t.index ['nkf_member_trial_id'], name: 'index_signups_on_nkf_member_trial_id', unique: true
    t.index ['user_id'], name: 'index_signups_on_user_id'
  end

  create_table 'survey_answer_translations', force: :cascade do |t|
    t.string 'answer', limit: 254, null: false
    t.string 'normalized_answer', limit: 254, null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'survey_answers', force: :cascade do |t|
    t.integer 'survey_request_id', null: false
    t.integer 'survey_question_id', null: false
    t.string 'answer', limit: 254, null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index ['survey_question_id'], name: 'fk__survey_answers_survey_question_id'
    t.index ['survey_request_id'], name: 'fk__survey_answers_survey_request_id'
  end

  create_table 'survey_questions', force: :cascade do |t|
    t.integer 'survey_id', null: false
    t.integer 'position', null: false
    t.string 'title', limit: 254, null: false
    t.string 'choices', limit: 254
    t.boolean 'select_multiple'
    t.boolean 'free_text'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index ['survey_id'], name: 'fk__survey_questions_survey_id'
  end

  create_table 'survey_requests', force: :cascade do |t|
    t.integer 'survey_id', null: false
    t.integer 'member_id', null: false
    t.text 'comment'
    t.datetime 'sent_at'
    t.datetime 'reminded_at'
    t.datetime 'completed_at'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index ['member_id'], name: 'fk__survey_requests_member_id'
    t.index %w[survey_id member_id], name: 'index_survey_requests_on_survey_id_and_member_id', unique: true
    t.index ['survey_id'], name: 'fk__survey_requests_survey_id'
  end

  create_table 'surveys', force: :cascade do |t|
    t.string 'category', limit: 8
    t.integer 'days_active'
    t.integer 'days_passive'
    t.integer 'days_left'
    t.integer 'group_id'
    t.boolean 'ready'
    t.string 'title', limit: 64, null: false
    t.integer 'position', null: false
    t.datetime 'expires_at'
    t.text 'header'
    t.text 'footer'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index ['group_id'], name: 'fk__surveys_group_id'
  end

  create_table 'technique_applications', force: :cascade do |t|
    t.string 'name', limit: 255, null: false
    t.string 'system', limit: 255, null: false
    t.integer 'rank_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'position', null: false
    t.index %w[rank_id name], name: 'index_technique_applications_on_rank_id_and_name', unique: true
    t.index ['rank_id'], name: 'fk__technique_applications_rank_id'
  end

  create_table 'technique_links', force: :cascade do |t|
    t.integer 'linkable_id', null: false
    t.string 'title', limit: 64
    t.string 'url', limit: 128, null: false
    t.integer 'position', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'linkable_type', null: false
    t.index %w[linkable_type linkable_id position], name: 'idx_technique_links_on_linkable_type_et_linkable_id_et_position', unique: true
    t.index %w[linkable_type linkable_id url], name: 'index_technique_links_on_linkable_type_and_linkable_id_and_url', unique: true
    t.index %w[linkable_type linkable_id], name: 'index_technique_links_on_linkable_type_and_linkable_id'
  end

  create_table 'user_images', force: :cascade do |t|
    t.integer 'user_id', null: false
    t.integer 'image_id', null: false
    t.string 'rel_type', limit: 16, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[user_id image_id rel_type], name: 'index_user_images_on_user_id_and_image_id_and_rel_type', unique: true
  end

  create_table 'user_messages', force: :cascade do |t|
    t.integer 'user_id', null: false
    t.string 'tag', limit: 64, null: false
    t.string 'key', limit: 64, null: false
    t.string 'from', null: false
    t.string 'subject', limit: 255, null: false
    t.datetime 'message_timestamp'
    t.string 'email_url', limit: 254
    t.string 'user_email', limit: 128
    t.string 'title', limit: 255
    t.text 'html_body'
    t.text 'plain_body'
    t.datetime 'sent_at'
    t.datetime 'read_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'fk__user_messages_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'login', limit: 80
    t.string 'salted_password', limit: 40
    t.string 'email', limit: 64
    t.string 'first_name', limit: 40
    t.string 'last_name', limit: 40
    t.string 'salt', limit: 40
    t.string 'role', limit: 40
    t.string 'security_token', limit: 40
    t.datetime 'token_expiry'
    t.boolean 'verified', default: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'billing_user_id'
    t.bigint 'contact_user_id'
    t.bigint 'guardian_1_id'
    t.bigint 'guardian_2_id'
    t.string 'address', limit: 100
    t.date 'birthdate'
    t.boolean 'gmaps'
    t.decimal 'latitude', precision: 8, scale: 6
    t.decimal 'longitude', precision: 9, scale: 6
    t.boolean 'male'
    t.string 'phone', limit: 32
    t.string 'postal_code', limit: 4
    t.datetime 'deleted_at'
    t.string 'kana'
    t.string 'locale', limit: 2, null: false
    t.integer 'height', limit: 2
    t.index ['billing_user_id'], name: 'index_users_on_billing_user_id'
    t.index ['contact_user_id'], name: 'index_users_on_contact_user_id'
    t.index ['guardian_1_id'], name: 'index_users_on_guardian_1_id'
    t.index ['guardian_2_id'], name: 'index_users_on_guardian_2_id'
  end

  create_table 'versions', force: :cascade do |t|
    t.string 'item_type', null: false
    t.integer 'item_id', null: false
    t.string 'event', null: false
    t.string 'whodunnit'
    t.jsonb 'object'
    t.datetime 'created_at'
    t.jsonb 'object_changes'
    t.index %w[item_type item_id], name: 'index_versions_on_item_type_and_item_id'
  end

  create_table 'wazas', force: :cascade do |t|
    t.string 'name', limit: 255, null: false
    t.string 'translation', limit: 255
    t.text 'description'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['name'], name: 'index_wazas_on_name', unique: true
  end

  add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'application_image_sequences', 'technique_applications'
  add_foreign_key 'application_steps', 'application_image_sequences'
  add_foreign_key 'application_videos', 'images'
  add_foreign_key 'application_videos', 'technique_applications'
  add_foreign_key 'appointments', 'members', name: 'fk_appointments_member_id'
  add_foreign_key 'appointments', 'roles', name: 'fk_appointments_role_id'
  add_foreign_key 'attendances', 'practices', name: 'fk_attendances_practice_id'
  add_foreign_key 'attendances', 'users'
  add_foreign_key 'basic_techniques', 'ranks', name: 'fk_basic_techniques_rank_id'
  add_foreign_key 'basic_techniques', 'wazas', name: 'fk_basic_techniques_waza_id'
  add_foreign_key 'card_keys', 'users'
  add_foreign_key 'censors', 'graduations', name: 'censors_graduation_id_fkey'
  add_foreign_key 'censors', 'members', name: 'censors_member_id_fkey'
  add_foreign_key 'curriculum_groups', 'martial_arts'
  add_foreign_key 'elections', 'events', column: 'annual_meeting_id'
  add_foreign_key 'elections', 'members', name: 'fk_elections_member_id'
  add_foreign_key 'elections', 'roles', name: 'fk_elections_role_id'
  add_foreign_key 'embu_part_videos', 'embu_parts'
  add_foreign_key 'embu_part_videos', 'images'
  add_foreign_key 'embu_parts', 'embus'
  add_foreign_key 'event_invitees', 'users'
  add_foreign_key 'front_page_sections', 'images'
  add_foreign_key 'front_page_sections', 'information_pages'
  add_foreign_key 'graduates', 'graduations', name: 'graduates_graduation_id_fkey'
  add_foreign_key 'graduates', 'members', name: 'graduates_member_id_fkey'
  add_foreign_key 'graduates', 'ranks', name: 'graduates_rank_id_fkey'
  add_foreign_key 'group_instructors', 'group_semesters', name: 'fk_group_instructors_group_semester_id'
  add_foreign_key 'group_memberships', 'groups', name: 'group_memberships_group_id_fkey'
  add_foreign_key 'group_memberships', 'users'
  add_foreign_key 'group_schedules', 'groups', name: 'group_schedules_group_id_fkey'
  add_foreign_key 'group_semesters', 'groups', name: 'fk_group_semesters_group_id'
  add_foreign_key 'group_semesters', 'members', column: 'chief_instructor_id', name: 'fk_group_semesters_chief_instructor_id'
  add_foreign_key 'group_semesters', 'semesters', name: 'fk_group_semesters_semester_id'
  add_foreign_key 'groups', 'curriculum_groups'
  add_foreign_key 'information_pages', 'information_pages', column: 'parent_id', name: 'information_pages_parent_id_fkey'
  add_foreign_key 'martial_arts', 'martial_arts', column: 'original_martial_art_id'
  add_foreign_key 'members', 'users'
  add_foreign_key 'news_item_likes', 'news_items', name: 'fk_news_item_likes_news_item_id'
  add_foreign_key 'news_item_likes', 'users', name: 'fk_news_item_likes_user_id'
  add_foreign_key 'news_items', 'users', column: 'created_by', name: 'news_items_created_by_fkey'
  add_foreign_key 'nkf_members', 'members', name: 'nkf_members_member_id_fkey'
  add_foreign_key 'practices', 'group_schedules', name: 'fk_practices_group_schedule_id'
  add_foreign_key 'rank_articles', 'information_pages'
  add_foreign_key 'rank_articles', 'ranks'
  add_foreign_key 'ranks', 'curriculum_groups'
  add_foreign_key 'signatures', 'users'
  add_foreign_key 'signups', 'nkf_member_trials'
  add_foreign_key 'signups', 'users'
  add_foreign_key 'survey_answers', 'survey_questions', name: 'fk_survey_answers_survey_question_id'
  add_foreign_key 'survey_answers', 'survey_requests', name: 'fk_survey_answers_survey_request_id'
  add_foreign_key 'survey_questions', 'surveys', name: 'fk_survey_questions_survey_id'
  add_foreign_key 'survey_requests', 'members', name: 'fk_survey_requests_member_id'
  add_foreign_key 'survey_requests', 'surveys', name: 'fk_survey_requests_survey_id'
  add_foreign_key 'surveys', 'groups', name: 'fk_surveys_group_id'
  add_foreign_key 'technique_applications', 'ranks', name: 'fk_technique_applications_rank_id'
  add_foreign_key 'technique_links', 'basic_techniques', column: 'linkable_id', name: 'fk_basic_technique_links_basic_technique_id'
  add_foreign_key 'user_messages', 'users', name: 'fk_user_messages_user_id'
  add_foreign_key 'users', 'users', column: 'billing_user_id'
  add_foreign_key 'users', 'users', column: 'contact_user_id'
  add_foreign_key 'users', 'users', column: 'guardian_1_id'
  add_foreign_key 'users', 'users', column: 'guardian_2_id'
end
