# frozen_string_literal: true

class EventGroup < ApplicationRecord
  belongs_to :event
  belongs_to :group

  validates :event_id, :group_id, presence: true
end
