require 'graduation_mailer'

class GraduationReminder
  def self.notify_missing_graduations
    today = Date.today
    groups = Group.active(today).to_a
    planned_groups = Graduation.where('held_on >= ?', today).to_a.map(&:group)
    missing_groups = groups - planned_groups
    missing_groups.each do |g|
      instructor = Semester.current.group_semesters.
          find { |gs| gs.group_id == g.id }.try(:chief_instructor)
      next unless instructor
      GraduationMailer.missing_graduation(instructor, g).deliver
    end
  rescue
    raise if Rails.env.test?
    logger.error "Exception sending missing graduations message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

  def self.notify_overdue_graduates
    today = Date.today
    members = Member.active(today).
        includes(:ranks, :attendances => {:practice => {:group_schedule => :group}}).
        to_a
    overdue_graduates = members.select do |m|
      next_rank = m.next_rank
      attendances = m.attendances_since_graduation
      minimum_attendances = next_rank.minimum_attendances
      next unless attendances.size >= minimum_attendances
      group = m.next_rank.group
      next if group.school_breaks? &&
          (group.next_graduation.nil? ||
              !m.active?(group.next_graduation.held_on))
      next if m.next_graduate
      true
    end
    GraduationMailer.overdue_graduates(overdue_graduates).deliver if overdue_graduates.any?
  rescue Exception
    raise if Rails.env.test?
    logger.error "Exception sending overdue graduates message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

  def self.notify_missing_aprovals
    Censor.includes(:graduation, :member).references(:graduations).
        where('approved_grades_at IS NULL AND graduations.held_on < CURRENT_DATE AND user_id IS NOT NULL').
        order('graduations.held_on').
        each do |e|
      GraduationMailer.missing_approval(e).deliver
    end
  rescue
    logger.error "Exception sending missing approvals message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

end
