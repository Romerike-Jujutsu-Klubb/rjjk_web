require 'graduation_mailer'

class GraduationReminder
  def self.notify_missing_graduations
    today = Date.today
    groups = Group.active(today).all
    planned_groups = Graduation.where('held_on >= ?', today).all.map(&:group)
    missing_groups = groups - planned_groups
    missing_groups.each do |g|
      instructors = GroupInstructor.includes(:group_schedule => :group).
          where('role = ? AND groups.id = ?', GroupInstructor::Role::CHIEF, g.id).
          all.select(&:active?).map(&:member).uniq
      next if instructors.empty?
      instructors.each do |i|
        GraduationMailer.missing_graduation(i, g).deliver
      end
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
        all
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
    logger.error "Exception sending overdue graduates message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

  def self.notify_missing_aprovals
    Censor.includes(:graduation, :member).
        where('approved_grades_at IS NULL AND graduations.held_on < CURRENT_DATE AND user_id IS NOT NULL').
        order(:held_on).
        each do |e|
      GraduationMailer.missing_approval(e).deliver
    end
  rescue
    logger.error "Exception sending missing approvals message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

end
