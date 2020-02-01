# frozen_string_literal: true

require 'test_helper'

class EventRegistrationControllerTest < ActionController::TestCase
  test 'allow registering with existing user with differently cased email' do
    assert_no_difference(-> { User.count }) do
      assert_difference(-> { EventInvitee.count }) do
        post :create, params: { event_invitee: {
          event_id: id(:one),
          user_attributes: { name: 'Test Testersen', email: 'LISE@example.com', phone: '' },
          organization: '',
        } }
      end
    end
    assert_redirected_to event_registration_path(EventInvitee.last)
  end
end
