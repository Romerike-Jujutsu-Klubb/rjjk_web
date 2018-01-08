# frozen_string_literal: true

class MemberUser < ApplicationRecord
  belongs_to :member
  belongs_to :user

  validates :relationship, uniqueness: true
end
