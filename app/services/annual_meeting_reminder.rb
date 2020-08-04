# frozen_string_literal: true

class AnnualMeetingReminder
  def self.notify_missing_date
    month = Date.current.mon
    return if month >= 3 && month < 11
    return if AnnualMeeting.exists?(['start_at >= ?', Date.current])

    am = AnnualMeeting.order(:start_at).last
    board_members = am.board_members
    board_members.each do |m|
      AnnualMeetingMailer.missing_date(m, am.start_at.year + 1).store(m, tag: :annual_meeting_missing_date)
    end
  end

  def self.notify_missing_invitation
    return if Date.current.mon >= 3 && Date.current.mon < 11

    next_meeting = AnnualMeeting.where('start_at >= ?', Date.current).order(:start_at).first
    return if next_meeting.try(:invitation_sent_at)
    return if next_meeting.start_at > 6.weeks.from_now

    am = AnnualMeeting.order(:start_at).last
    am.board_members.each do |m|
      AnnualMeetingMailer.missing_invitation(next_meeting, m)
          .store(m, tag: :annual_meeting_missing_invitation)
    end
  end
end
