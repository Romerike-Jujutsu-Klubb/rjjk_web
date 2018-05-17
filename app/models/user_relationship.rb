# frozen_string_literal: true

class UserRelationship < ApplicationRecord
  module Kind
    PARENT_1 = 'PARENT_1'
    PARENT_2 = 'PARENT_2'
  end

  belongs_to :upstream_user, class_name: :User, inverse_of: :downstream_user_relationships
  belongs_to :downstream_user, class_name: :User, inverse_of: :user_relationships

  before_validation do
    logger.info self.class
    logger.info inspect
  end

  validates :kind, presence: true, uniqueness: { scope: :downstream_user_id },
      inclusion: Kind.constants.map(&:to_s)
end
