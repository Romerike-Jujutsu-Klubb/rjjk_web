# frozen_string_literal: true
class EventGroup < ActiveRecord::Base
  belongs_to :event
  belongs_to :group

  validates :event_id, :group_id, presence: true
end
