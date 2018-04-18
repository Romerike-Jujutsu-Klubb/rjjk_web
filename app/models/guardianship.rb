# frozen_string_literal: true

class Guardianship < ApplicationRecord
  belongs_to :guardian_user, class_name: :User, inverse_of: :wards
  belongs_to :ward_user, class_name: :User, inverse_of: :guardianships

  validates :index, presence: true, uniqueness: { scope: :ward_user_id },
      numericality: { minimum: 1 }

  def relationship
    :"parent_#{index}"
  end
end
