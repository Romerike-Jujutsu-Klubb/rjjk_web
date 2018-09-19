# frozen_string_literal: true

class CreateNkfMembers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :nkf_members do |t|
      t.integer :member_id

      t.integer :medlemsnummer
      t.string :etternavn
      t.string :fornavn
      t.string :adresse_1
      t.string :adresse_2
      t.string :adresse_3
      t.string :postnr
      t.string :sted
      t.string :fodselsdato
      t.string :telefon
      t.string :telefon_arbeid
      t.string :mobil
      t.string :epost
      t.string :epost_faktura
      t.string :yrke
      t.string :medlemsstatus
      t.string :medlemskategori
      t.string :medlemskategori_navn
      t.string :kont_sats
      t.string :kont_belop
      t.string :kontraktstype
      t.string :kontraktsbelop
      t.string :rabatt
      t.string :gren_stilart_avd_parti___gren_stilart_avd_parti
      t.string :sist_betalt_dato
      t.string :betalt_t_o_m__dato
      t.string :konkurranseomrade_id, references: nil
      t.string :konkurranseomrade_navn
      t.string :klubb_id, references: nil
      t.string :klubb
      t.integer :hovedmedlem_id, references: nil
      t.string :hovedmedlem_navn
      t.string :innmeldtdato
      t.string :innmeldtarsak
      t.string :utmeldtdato
      t.string :utmeldtarsak
      t.string :antall_etiketter_1
      t.timestamps
    end
  end

  def self.down
    drop_table :nkf_members
  end
end
