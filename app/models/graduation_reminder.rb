require 'graduation_mailer'

class GraduationReminder
  def self.notify_missing_graduations
    today = Date.today
    groups = Group.active(today).all
    planned_groups = Graduation.where('held_on >= ?', today).all.map(&:group)
    missing_groups = groups - planned_groups
    missing_groups.each do |g|
      instructor = g.current_semester.try(:group_instructor).try(:member)
      next unless instructor
      GraduationMailer.missing_graduation(instructor, g).deliver
    end
  rescue
    logger.error "Exception sending missing graduations message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

  def self.notify_overdue_graduates
    today = Date.today
    members = Member.active(today).all
    overdue_graduates = members.select do |m|
      next_rank = m.next_rank
      attendances = m.attendances_since_graduation
      minimum_attendances = next_rank.minimum_attendances
      attendances.size >= minimum_attendances
    end
    GraduationMailer.overdue_graduates(overdue_graduates).deliver if overdue_graduates.any?
  rescue
    logger.error "Exception sending overdue graduates message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

end
