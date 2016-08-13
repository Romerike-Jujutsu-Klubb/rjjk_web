class CreateUserMessages < ActiveRecord::Migration
  def change
    create_table :user_messages do |t|
      t.integer :user_id, null: false
      t.string :tag, limit: 64
      t.string :from, null: false
      t.string :subject, null: false, limit: 160
      t.string :key, null: false, limit: 64
      t.text :html_body
      t.text :plain_body
      t.datetime :sent_at
      t.datetime :read_at

      t.timestamps null: false
    end
  end
end
