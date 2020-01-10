# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include UserSystem
  include ApplicationRecordCopier
  self.abstract_class = true
end
