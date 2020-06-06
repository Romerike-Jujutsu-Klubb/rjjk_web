# frozen_string_literal: true

class InformationPage < ApplicationRecord
  acts_as_tree
  acts_as_list scope: :parent_id

  has_many :front_page_sections, dependent: :restrict_with_error
  has_many :rank_articles, dependent: :destroy

  before_validation { body&.strip! }

  scope :for_all, -> { where public: true }

  validates :title, uniqueness: { scope: :parent_id, case_sensitive: false }

  def visible?
    !hidden
  end

  def ingress
    paragraphs&.reject{_1 =~ /^!\[|^#/}&.first
  end

  private

  def paragraphs
    body&.split(/\r?\n\r?\n/)
  end
end
