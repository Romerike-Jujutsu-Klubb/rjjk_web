# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include UserSystem
  self.abstract_class = true
end
