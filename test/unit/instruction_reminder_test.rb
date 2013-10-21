require 'test_helper'
class InstructionReminderTest < ActionMailer::TestCase
  def test_notify_missing_instructors
    InstructionReminder.notify_missing_instructors

    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = Mail::TestMailer.deliveries[0]
    assert_equal %w(uwe@kubosch.no), mail.to_addrs
    assert_match /Grupper som mangler instruktør/, mail.decoded
    assert_match %r{/group_instructors/new\?group_instructor%5Bgroup_schedule_id%5D=767635258&amp;group_instructor%5Brole%5D=Hovedinstrukt%C3%B8r&amp;group_instructor%5Bsemester_id%5D=485700622">Tirsdag</a>}, mail.decoded
  end
end
