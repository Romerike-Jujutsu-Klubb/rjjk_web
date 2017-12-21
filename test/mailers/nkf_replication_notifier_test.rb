# frozen_string_literal: true

require 'test_helper'

class NkfReplicationNotifierTest < ActionMailer::TestCase
  test 'notify_wrong_contracts' do
    assert_mail_stored { NkfReplicationNotifier.notify_wrong_contracts }
    mail = UserMessage.pending[0]
    assert_match(/Uwe Kubosch/, mail.body)
    assert_match(/Lars Bråten/, mail.body)
  end
end
