# frozen_string_literal: true

class RankArticle < ApplicationRecord
  acts_as_list

  belongs_to :information_page
  belongs_to :rank
end
