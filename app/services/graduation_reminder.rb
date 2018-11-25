# frozen_string_literal: true

require 'graduation_mailer'

class GraduationReminder
  EXAMINER_REGISTRATION_LIMIT = 6.weeks
  EXAMINER_LOCK_LIMIT = 5.weeks
  CHIEF_INSTRUCTOR_LOCK_LIMIT = 4.weeks
  GRADUATES_INVITATION_LIMIT = 3.weeks

  def self.notify_missing_graduations
    today = Date.current
    groups = Group.active(today).to_a
    planned_groups = Graduation.where('held_on >= ?', today).to_a.map(&:group)
    missing_groups = groups - planned_groups
    month_start = Date.civil(today.year, today.mon >= 7 ? 12 : 6)
    return if month_start > 4.months.from_now

    missing_groups.each do |g|
      instructor = Semester.current.group_semesters.find { |gs| gs.group_id == g.id }
          &.chief_instructor
      next unless instructor

      suggested_date = g.suggested_graduation_date(today)
      next if suggested_date <= today || suggested_date > 6.months.from_now

      GraduationMailer.missing_graduation(instructor, g, suggested_date)
          .store(instructor, tag: :missing_graduation)
    end
  end

  def self.notify_groups
    Graduation.upcoming.includes(:group).references(:groups)
        .where('held_on < ?', 3.months.from_now)
        .where('group_notification = ?', true)
        .where('date_info_sent_at IS NULL')
        .order(:id)
        .each do |graduation|
      graduation.group.members.active(graduation.held_on).order(:id).each do |member|
        next if member.next_rank(graduation).position >= Rank::SHODAN_POSITION
        next if member.passive?

        GraduationMailer.group_date_info(graduation, member)
            .store(member, tag: :graduation_date_info)
      end
      graduation.update! date_info_sent_at: Time.current
    end
  end

  def self.notify_overdue_graduates
    today = Date.current
    members = Member.active(today)
        .includes(:ranks, attendances: { practice: { group_schedule: :group } })
        .to_a
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
    return if overdue_graduates.empty?

    # TODO(uwe): Send to chief instructor for each group
    GraduationMailer.overdue_graduates(overdue_graduates)
        .store(Role[:'Hovedinstruktør'], tag: :overdue_graduates)
  end

  def self.notify_missing_censors
    Graduation.upcoming.includes(:group).references(:groups)
        .where('held_on < ?', EXAMINER_REGISTRATION_LIMIT.from_now)
        .where('notified_missing_censors_at IS NULL OR notified_missing_censors_at < ?', 1.week.ago)
        .order(:id)
        .each do |graduation|
      next if graduation.censors.select(&:examiner?).any?

      instructor = graduation.group.current_semester&.chief_instructor || Role[:Hovedinstruktør]
      GraduationMailer.missing_censors(graduation, instructor)
          .store(instructor, tag: :graduation_missing_censors)
      graduation.update! notified_missing_censors_at: Time.current
    end
  end

  def self.notify_censors
    Censor.includes(:graduation, :member).references(:graduations)
        .where('censors.created_at <= ?', 1.hour.ago)
        .where('graduations.held_on >= ?', Date.current)
        .where(confirmed_at: nil)
        .where('requested_at IS NULL OR requested_at < ?', 1.week.ago)
        .order('graduations.held_on, censors.id')
        .each do |censor|
      GraduationMailer.invite_censor(censor).store(censor.member, tag: :censor_invite)
      censor.update! requested_at: Time.zone.now
    end
  end

  def self.notify_missing_locks
    Censor.includes(:graduation, :member).references(:graduations)
        .where.not(confirmed_at: nil)
        .where.not(declined: true)
        .where(locked_at: nil)
        .where('lock_reminded_at IS NULL OR lock_reminded_at < ?', 1.week.ago)
        .where('graduations.held_on < ?', EXAMINER_LOCK_LIMIT.from_now)
        .order('graduations.held_on')
        .select(&:should_lock?)
        .each do |censor|
      GraduationMailer.lock_reminder(censor).store(censor.member, tag: :censor_lock_reminder)
      censor.update! lock_reminded_at: Time.zone.now
    end
  end

  def self.send_shopping_list
    Graduation.upcoming
        .ready(1.day.ago)
        .where('graduations.held_on < ?', 10.days.from_now)
        .where(shopping_list_sent_at: nil)
        .order('graduations.held_on')
        .each do |graduation|
      next if graduation.graduates.empty?

      eq_manager = Role['Materialforvalter', return_record: true]
      GraduationMailer.send_shopping_list(graduation, eq_manager)
          .store(eq_manager.member, tag: :graduation_shopping_list)
      graduation.update! shopping_list_sent_at: Time.zone.now
    end
  end

  def self.invite_graduates
    Graduate.includes(graduation: %i[censors group]).references(:groups)
        .where('graduations.held_on BETWEEN ? AND ?',
            Date.current, GRADUATES_INVITATION_LIMIT.from_now)
        .where.not(passed: false)
        .where('graduates.confirmed_at IS NULL')
        .where('graduates.invitation_sent_at IS NULL OR graduates.invitation_sent_at < ?',
            1.week.ago)
        .order('graduations.held_on')
        .each do |graduate|

      # TODO(uwe): Solve in SQL
      next unless graduate.graduation.censors.select(&:examiner?).any?
      next unless graduate.graduation.censors.select(&:examiner?).all?(&:approved_graduates?)

      # ODOT

      GraduationMailer.invite_graduate(graduate)
          .store(graduate.member, tag: :graduate_invite)
      graduate.update! invitation_sent_at: Time.current
    end
  end

  # FIXME(uwe): Added/removed, date/time change, planned rank
  def self.notify_graduate_changes
    Graduate.includes(graduation: %i[censors group]).references(:groups)
        .where('graduations.held_on BETWEEN ? AND ?',
            Date.current, GRADUATES_INVITATION_LIMIT.from_now)
        .where('invitation_sent_at IS NOT NULL AND invitation_sent_at < graduates.updated_at')
        .order('graduations.held_on')
        .each do |graduate|

      # TODO(uwe): Solve in SQL
      next unless graduate.graduation.censors.select(&:examiner?).any?
      next unless graduate.graduation.censors.select(&:examiner?).all?(&:approved_graduates?)

      # ODOT

      GraduationMailer.invite_graduate(graduate)
          .store(graduate.member, tag: :graduate_changes)
      graduate.update! invitation_sent_at: Time.current
    end
  end

  def self.notify_missing_approvals
    Censor.includes(:graduation, :member).references(:graduations)
        .where('declined IS NULL OR declined = ?', false)
        .where('graduations.held_on < ?', Date.current)
        .where(approved_grades_at: nil)
        .where('approval_requested_at IS NULL OR approval_requested_at <= ?', 1.day.ago)
        .order(:id)
        .each do |censor|
      next unless censor.examiner? ||
          censor.graduation.censors.select(&:examiner?).all?(&:approved?)

      GraduationMailer.missing_approval(censor).store(censor.member, tag: :censor_missing_approval)
      censor.update! approval_requested_at: Time.current
    end
  end

  def self.congratulate_graduates
    Graduation.approved(2.days.ago).includes(:group).references(:groups)
        .where('held_on BETWEEN ? AND ?', 6.months.ago, 1.week.ago)
        .order(:held_on)
        .each do |graduation|
      graduation.graduates.where(gratz_sent_at: nil, passed: true).each do |graduate|
        GraduationMailer.congratulate_graduate(graduate)
            .store(graduate.member, tag: :graduate_gratz)
        graduate.update! gratz_sent_at: Time.current
      rescue
        raise "Exception congratulating graduate: #{graduate.id}"
      end
    end
  end
end
