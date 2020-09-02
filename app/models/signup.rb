# frozen_string_literal: true

class Signup < ApplicationRecord
  belongs_to :user
  belongs_to :nkf_member_trial
end
