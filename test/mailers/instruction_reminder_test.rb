# frozen_string_literal: true

require 'test_helper'
class InstructionReminderTest < ActionMailer::TestCase
  def test_notify_missing_instructors
    InstructionReminder.notify_missing_instructors

    assert_equal 1, UserMessage.pending.size
    mail = UserMessage.pending[0]
    assert_equal ['uwe@example.com'], mail.to
    assert_match(/Grupper som mangler hovedinstruktør/, mail.body)
    assert_match %r{/group_semesters/56175819/edit">Tiger</a>}, mail.body
    assert_match(/Grupper som mangler instruktør/, mail.body)
    assert_match %r{/group_instructors/new\?
          group_instructor%5Bgroup_schedule_id%5D=767635258
          &amp;group_instructor%5Bgroup_semester_id%5D=56175819">Tiger</a>}x,
        mail.body
    assert_match %r{/group_instructors/new\?
          group_instructor%5Bgroup_schedule_id%5D=584432663
          &amp;group_instructor%5Bgroup_semester_id%5D=56175819">Tiger</a>}x,
        mail.body
  end
end
