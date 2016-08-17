# frozen_string_literal: true
class AnnualMeetingReminder
  def self.notify_missing_date
    month = Date.today.mon
    return if month >= 2 && month < 10
    return if AnnualMeeting.where('start_at >= ?', Date.today).exists?
    am = AnnualMeeting.order(:start_at).last
    board_members = am.board_members
    board_members.each do |m|
      AnnualMeetingMailer.missing_date(m, am.start_at.year + 1)
          .store(m.user_id, tag: :annual_meeting_missing_date)
    end
  rescue Exception
    raise if Rails.env.test?
    logger.error "Exception sending missing annual meeting date reminder: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

  def self.notify_missing_invitation
    return if Date.today.mon >= 2 && Date.today.mon < 10
    next_meeting = AnnualMeeting.where('start_at >= ?', Date.today)
        .order(:start_at).first
    return if next_meeting.try(:invitation_sent_at)
    return if next_meeting.start_at > 6.weeks.from_now
    am = AnnualMeeting.order(:start_at).last
    am.board_members.each do |m|
      AnnualMeetingMailer.missing_invitation(next_meeting, m).store(m.user_id, tag: :annual_meeting_missing_invitation)
    end
  rescue Exception
    raise if Rails.env.test?
    logger.error "Exception sending overdue graduates message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end
end
