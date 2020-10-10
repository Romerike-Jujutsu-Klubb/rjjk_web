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
    trial_import = Mocha::Mock.new('trial_import')
    NkfReplicationMailer.import_changes(import, trial_import)
  end

  def update_members
    NkfReplicationMailer.update_members(NkfMemberComparison.new.sync)
  end

  def update_appointments
    NkfReplicationMailer.update_appointments(Practice.where.not(message: nil).first,
        GroupSchedule.first, User.first, Member.first(5), Member.last(5))
  end
end
