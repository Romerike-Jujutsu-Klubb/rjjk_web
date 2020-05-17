# frozen_string_literal: true

module Linkable
  extend ActiveSupport::Concern

  included do
    has_many :technique_links, dependent: :destroy, as: :linkable
  end

  def label
    "#{name} (#{rank.name})"
  end
end
