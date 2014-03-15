class CreateAttacks < ActiveRecord::Migration
  def change
    create_table :attacks do |t|
      t.string :name
      t.string :translation
      t.string :description

      t.timestamps
    end
  end
end
