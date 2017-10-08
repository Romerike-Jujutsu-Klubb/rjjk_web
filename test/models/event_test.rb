# frozen_string_literal: true

require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  def test_update_with_invities
    events(:one).update! invitees: 'user@example.com,User <user@@example.com>,Uwe'
  end
end
