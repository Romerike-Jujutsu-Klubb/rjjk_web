# frozen_string_literal: true

class UserEmail < ApplicationRecord
  belongs_to :user
end
