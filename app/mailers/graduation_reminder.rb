require 'graduation_mailer'

class GraduationReminder
  def self.notify_missing_graduations
    today = Date.today
    groups = Group.active(today).to_a
    planned_groups = Graduation.where('held_on >= ?', today).to_a.map(&:group)
    missing_groups = groups - planned_groups
    month_start = Date.civil(Date.today.year, (Date.today.mon >= 6) ? 12 : 6)
    second_week = month_start + (7 - month_start.wday)
    missing_groups.each do |g|
      instructor = Semester.current.group_semesters.
          find { |gs| gs.group_id == g.id }.try(:chief_instructor)
      next unless instructor

      suggested_date = second_week + g.group_schedules.first.weekday
      next if suggested_date <= Date.today

      GraduationMailer.missing_graduation(instructor, g, suggested_date)
          .store(instructor, tag: :missing_graduation)
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
        includes(:ranks, attendances: { practice: { :group_schedule => :group } }).
        to_a
    overdue_graduates = members.select do |m|
      minimum_attendances = m.next_rank.minimum_attendances
      attendances_since_graduation = m.attendances_since_graduation.size
      next unless attendances_since_graduation >= minimum_attendances
      group = m.next_rank.group
      next if group.school_breaks? &&
          (group.next_graduation.nil? ||
              !m.active?(group.next_graduation.held_on))
      next if m.next_graduate
      true
    end
    if overdue_graduates.any?
      # TODO(uwe): Send to chief instructor for each group
      GraduationMailer.overdue_graduates(overdue_graduates)
          .store(Role[:'Hovedinstruktør'], tag: :overdue_graduates)
    end
  rescue Exception
    raise if Rails.env.test?
    logger.error "Exception sending overdue graduates message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

  def self.notify_censors
    Censor.includes(:graduation, :member).references(:graduations)
        .where('(examiner IS NULL OR examiner = ?) AND confirmed_at IS NULL AND (requested_at IS NULL OR requested_at < ?)', false, 1.week.ago)
        .order('graduations.held_on')
        .limit(1)
        .each do |censor|
      GraduationMailer.invite_censor(censor).store(censor.member.user_id, tag: :censor_invite)
      censor.update! requested_at: Time.zone.now
    end
  rescue
    logger.error "Exception sending censor invitation: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

  def self.notify_missing_aprovals
    Censor.includes(:graduation, :member).references(:graduations).
        where('approved_grades_at IS NULL AND graduations.held_on < CURRENT_DATE AND user_id IS NOT NULL').
        order('graduations.held_on').
        each do |censor|
      GraduationMailer.missing_approval(censor).store(censor.member.user_id)
    end
  rescue
    logger.error "Exception sending missing approvals message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

end
