# frozen_string_literal: true

class MemberImage < ApplicationRecord
  belongs_to :image
  belongs_to :member
end
