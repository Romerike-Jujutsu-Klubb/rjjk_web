# frozen_string_literal: true
require 'test_helper'

class NkfReplicationNotifierTest < ActionMailer::TestCase
  test 'notify_wrong_contracts' do
    assert_mail_stored(0) { NkfReplicationNotifier.notify_wrong_contracts }
  end
end
