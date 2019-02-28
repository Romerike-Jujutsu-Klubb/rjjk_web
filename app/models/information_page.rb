# frozen_string_literal: true

class InformationPage < ApplicationRecord
  acts_as_tree
  acts_as_list scope: :parent_id

  before_validation { body&.strip! }

  scope :for_all, -> { where public: true }

  validates :title, uniqueness: { scope: :parent_id, case_sensitive: false }

  def visible?
    !hidden
  end
end
