# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 2) do

  create_table "information_pages", :force => true do |t|
    t.column "parent_id", :integer
    t.column "title", :string, :limit => 32, :default => "", :null => false
    t.column "body", :text
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "news_items", :force => true do |t|
    t.column "title", :string, :limit => 32, :default => "", :null => false
    t.column "body", :text
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "users", :force => true do |t|
    t.column "login", :string, :limit => 80, :default => "", :null => false
    t.column "salted_password", :string, :limit => 40, :default => "", :null => false
    t.column "email", :string, :limit => 60, :default => "", :null => false
    t.column "first_name", :string, :limit => 40
    t.column "last_name", :string, :limit => 40
    t.column "salt", :string, :limit => 40, :default => "", :null => false
    t.column "verified", :integer, :default => 0
    t.column "role", :string, :limit => 40
    t.column "security_token", :string, :limit => 40
    t.column "token_expiry", :datetime
    t.column "deleted", :integer, :default => 0
    t.column "delete_after", :datetime
  end

end
