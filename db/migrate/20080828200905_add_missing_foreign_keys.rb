# frozen_string_literal: true
class AddMissingForeignKeys < ActiveRecord::Migration
  def self.up
    # This was only necessary before adding the foreign_key_migrations plugin

    # execute 'delete from graduates where member_id not in (select id from members)'
    # add_foreign_key "censors", ["graduation_id"], "graduations", ["id"], :name => "censors_graduation_id_fkey"
    # add_foreign_key "censors", ["member_id"], "members", ["id"], :name => "censors_member_id_fkey"

    # add_foreign_key "graduates", ["member_id"], "members", ["id"], :name => "graduates_member_id_fkey"
    # add_foreign_key "graduates", ["graduation_id"], "graduations", ["id"], :name => "graduates_graduation_id_fkey"
    # add_foreign_key "graduates", ["rank_id"], "ranks", ["id"], :name => "graduates_rank_id_fkey"

    # add_foreign_key "graduations", ["martial_art_id"], "martial_arts", ["id"], :name => "graduations_martial_art_id_fkey"

    # add_foreign_key "information_pages", ["parent_id"], "information_pages", ["id"], :name => "information_pages_parent_id_fkey"

    # add_foreign_key "ranks", ["martial_art_id"], "martial_arts", ["id"], :name => "ranks_martial_art_id_fkey"
  end

  def self.down
  end
end
