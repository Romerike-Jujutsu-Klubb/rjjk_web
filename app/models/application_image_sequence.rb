# frozen_string_literal: true

class ApplicationImageSequence < ApplicationRecord
  acts_as_list

  belongs_to :technique_application
end
