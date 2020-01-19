# frozen_string_literal: true

module EventRegistrationHelper
  def event_registration_link(event)
    event.registration_url || new_event_registration_path(event_invitee: { event_id: event.id })
  end
end
