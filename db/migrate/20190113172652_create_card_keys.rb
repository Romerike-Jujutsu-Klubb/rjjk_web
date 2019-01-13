class CreateCardKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :card_keys do |t|
      t.string :label, null: false
      t.references :user, foreign_key: true
      t.boolean :office_key
      t.text :comment

      t.timestamps
    end
  end
end
