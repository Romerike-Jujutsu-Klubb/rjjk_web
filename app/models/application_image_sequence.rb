# frozen_string_literal: true

class ApplicationImageSequence < ApplicationRecord
  acts_as_list scope: :technique_application_id

  belongs_to :technique_application

  has_many :application_steps, dependent: :destroy
end
