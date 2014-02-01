class AnnualMeetingReminder
  def self.notify_missing_date
    return if AnnualMeeting.where('start_at >= ?', Date.today.beginning_of_year).
        exists?
    # FIXME(uwe): Send to the board
    Member.where('email = ?', 'uwe@kubosch.no').each do |m|
      AnnualMeetingMailer.missing_date(m).deliver
    end
  rescue
    logger.error "Exception sending missing annual meeting date reminder: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

  def self.notify_missing_invitation
    today = Date.today
    members = Member.active(today).
        includes(:ranks, :attendances => {:practice => {:group_schedule => :group}}).
        all
    overdue_graduates = members.select do |m|
      next_rank = m.next_rank
      attendances = m.attendances_since_graduation
      minimum_attendances = next_rank.minimum_attendances
      attendances.size >= minimum_attendances
    end
    AnnualMeetingMailer.create_missing_invitation(overdue_graduates).deliver if overdue_graduates.any?
  rescue Exception
    logger.error "Exception sending overdue graduates message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

end
