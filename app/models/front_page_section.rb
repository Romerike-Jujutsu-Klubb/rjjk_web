# frozen_string_literal: true

class FrontPageSection < ApplicationRecord
  acts_as_list

  belongs_to :image
  belongs_to :information_page
end
