# frozen_string_literal: true

class AddMoreFieldsToNkfMemberTrials < ActiveRecord::Migration[6.0]
  def change
    rename_column :nkf_member_trials, :adresse, :adresse_2
    rename_column :nkf_member_trials, :fodtdato, :fodselsdato
    rename_column :nkf_member_trials, :reg_dato, :innmeldtdato
    rename_column :nkf_member_trials, :stilart, :gren_stilart_avd_parti___gren_stilart_avd_parti

    add_column :nkf_member_trials, :foresatte, :string, limit: 64
    add_column :nkf_member_trials, :foresatte_epost, :string, limit: 64
    add_column :nkf_member_trials, :foresatte_mobil, :string, limit: 25
    add_column :nkf_member_trials, :foresatte_nr_2, :string, limit: 64
    add_column :nkf_member_trials, :foresatte_nr_2_mobil, :string, limit: 25
    add_column :nkf_member_trials, :hoyde, :smallint
    add_column :nkf_member_trials, :kont_sats, :string
    add_column :nkf_member_trials, :kontraktsbelop, :string
    add_column :nkf_member_trials, :kontraktstype, :string
    add_column :nkf_member_trials, :medlemskategori_navn, :string
    add_column :nkf_member_trials, :rabatt, :string
    add_column :nkf_member_trials, :telefon, :string, limit: 25
    add_column :nkf_member_trials, :telefon_arbeid, :string, limit: 25

    remove_column :nkf_member_trials, :alder, :string
    remove_column :nkf_member_trials, :medlems_type, :string
    remove_column :nkf_member_trials, :res_sms, :string
    remove_column :nkf_member_trials, :sted, :string
  end
end
