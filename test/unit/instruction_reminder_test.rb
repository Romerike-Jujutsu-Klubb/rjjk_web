# encoding: utf-8
require 'test_helper'
class InstructionReminderTest < ActionMailer::TestCase
  def test_notify_missing_instructors
    InstructionReminder.notify_missing_instructors

    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = Mail::TestMailer.deliveries[0]
    assert_equal 'uwe@kubosch.no', mail.to_addrs[0].to_s
    assert_match /Grupper som mangler instrukt=C3=B8r/, mail.encoded
  end
end
