# encoding: utf-8
class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string :category, limit: 8 # passive/active/left
      t.integer :days_active
      t.integer :days_passive
      t.integer :days_left
      t.integer :group_id
      t.boolean :ready
      t.string :title, null: false, limit: 64
      t.integer :position, null: false
      t.datetime :expires_at
      t.text :header
      t.text :footer

      t.timestamps
    end
    Survey.create! title: 'Velkommen til Romerike Jujutsu Klubb!',
        header: 'Vi er veldig glade for at du har startet å trene hos oss.  For å få oversikt over hvordan våre medlemmer får høre om oss, ønsker vi at du svarer på noen spørsmål.',
        footer: 'Tusen takk for at du tok deg tid til å svare på spørsmålene.  Det vil hjelpe oss å verve nye treningspartnere for deg.  Sees på trening!'
  end
end
