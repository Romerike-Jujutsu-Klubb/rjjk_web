# frozen_string_literal: true

class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, null: false, limit: 32
      t.integer :years_on_the_board

      t.timestamps
    end

    execute "INSERT INTO roles(created_at, updated_at, name, years_on_the_board)
        VALUES ('2014-03-03', '2014-03-03', 'Leder', 2)"
    execute "INSERT INTO roles(created_at, updated_at, name, years_on_the_board)
        VALUES ('2014-03-03', '2014-03-03', 'Kasserer', 2)"
    execute "INSERT INTO roles(created_at, updated_at, name, years_on_the_board)
        VALUES ('2014-03-03', '2014-03-03', 'Foreldrerepresentant', 1)"
  end
end
