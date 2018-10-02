# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/attendance_mailer
class AttendanceMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/attendance_mailer/plan
  def plan
    AttendanceMailer.plan
  end

  # Preview this email at http://localhost:3000/rails/mailers/attendance_mailer/message_reminder
  def message_reminder
    AttendanceMailer.message_reminder
  end

  # Preview this email at http://localhost:3000/rails/mailers/attendance_mailer/summary
  def summary
    AttendanceMailer.summary(Practice.where.not(message: nil).first, GroupSchedule.first, User.first,
        Member.first(5), Member.last(5))
  end

  # Preview this email at http://localhost:3000/rails/mailers/attendance_mailer/changes
  def changes
    practice = Practice.where.not(message: nil).first
    group_schedule = GroupSchedule.first
    recipient = User.first
    new_attendees = Member.first(5)
    new_absentees = Member.last(5)
    attendees = Member.first(10)
    AttendanceMailer.changes(practice, group_schedule, recipient, new_attendees, new_absentees, attendees)
  end

  # Preview this email at http://localhost:3000/rails/mailers/attendance_mailer/review
  def review
    AttendanceMailer.review
  end
end
