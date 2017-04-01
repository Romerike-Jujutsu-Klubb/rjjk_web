# frozen_string_literal: true
class NewsItemLike < ApplicationRecord
  belongs_to :news_item
  belongs_to :user
end
