# frozen_string_literal: true
class AddMissingTimestamps < ActiveRecord::Migration
  def change
    add_timestamps :censors
    add_timestamps :graduates
    add_timestamps :graduations
    add_timestamps :martial_arts
    add_timestamps :members
    add_timestamps :ranks
    add_timestamps :users
  end
end
