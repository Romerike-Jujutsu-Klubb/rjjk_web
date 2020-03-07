# frozen_string_literal: true

class RemoveVerificationForNilEmailsOnUsers < ActiveRecord::Migration[6.0]
  def up
    execute 'UPDATE users SET verified = false WHERE email IS NULL'
  end
end
