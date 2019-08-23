# frozen_string_literal: true

class NkfReplicationMailerPreview < ActionMailer::Preview
  def import_changes
    import = Mocha::Mock.new('import')
    import.stubs(:size).returns(1)
    import.stubs(:new_records).returns([{ record: NkfMember.first }])
    import.stubs(:changes).returns([{ record: NkfMemberTrial.first, changes: { a: :b } }])
    import.stubs(:trial_changes).returns([{ record: NkfMemberTrial.first, changes: { a: :b } }])
    import.stubs(:error_records).returns([])
    import.stubs(:import_rows).returns([1])
    import.stubs(:exception).returns(nil)
    NkfReplicationMailer.import_changes(import)
  end

  def update_members
    NkfReplicationMailer.update_members(NkfMemberComparison.new.sync)
  end

  def update_appointments
    NkfReplicationMailer.update_appointments(Practice.where.not(message: nil).first, GroupSchedule.first, User.first,
        Member.first(5), Member.last(5))
  end

  def wrong_contracts
    practice = Practice.where.not(message: nil).first
    group_schedule = GroupSchedule.first
    recipient = User.first
    new_attendees = Member.first(5)
    new_absentees = Member.last(5)
    attendees = Member.first(10)
    NkfReplicationMailer.wrong_contracts(practice, group_schedule, recipient, new_attendees, new_absentees, attendees)
  end
end
