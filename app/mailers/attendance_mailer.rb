# frozen_string_literal: true
class AttendanceMailer < ActionMailer::Base
  include UserSystem
  include MailerHelper

  default from: noreply_address

  def plan(member)
    @member = member
    @title = 'Planlegging oppmøte'
    @timestamp = Time.now
    @email_url = with_login(member.user, controller: :attendances, action: :plan)
    mail to: member.email, subject: 'Kommer du?'
  end

  def message_reminder(practice, instructor)
    @practice = practice
    @instructor = instructor
    @title = "Tema for morgendagens trening for #{practice.group_schedule.group.name}"
    @timestamp = @practice.date
    @email_url = with_login(instructor.user, controller: :practices, action: :edit, id: practice.id)
    mail to: @instructor.email, subject: @title
  end

  def summary(practice, group_schedule, recipient, attendees, _absentees)
    @practice = practice
    @group_schedule = group_schedule
    @recipient = recipient
    @members = attendees
    @title = "Trening i #{group_schedule.start_at.day_phase}"
    @title = "Trening i #{@group_schedule.start_at.day_phase}: #{attendees.empty? ? 'Ingen' : attendees.size} deltaker#{'e' if attendees.size > 1} påmeldt"
    @timestamp = Time.now
    @email_url = with_login(recipient.user, controller: :attendances, action: :plan)
    mail to: recipient.email, subject: @title
  end

  def changes(practice, group_schedule, recipient, new_attendees, new_absentees, attendees)
    @practice = practice
    @group_schedule = group_schedule
    @recipient = recipient
    @new_attendees = new_attendees
    @new_absentees = new_absentees
    @attendees = attendees
    change_msg = []
    if new_attendees.any?
      change_msg << "#{new_attendees.size} ny#{'e' if new_attendees.size > 1} deltaker#{'e' if new_attendees.size > 1} påmeldt"
    end
    change_msg << "#{new_absentees.size} avbud" if new_absentees.any?
    @title = "Trening i #{@group_schedule.start_at.day_phase}: #{change_msg.join(', ')}"
    @timestamp = Time.now
    @email_url = with_login(recipient.user, controller: :attendances, action: :plan)
    mail to: recipient.email, subject: @title
  end

  def review(member, completed_attendances, older_attendances)
    @member = member
    @completed_attendances = completed_attendances
    @older_attendances = older_attendances
    @title = 'Hvordan var treningen?'
    @timestamp = completed_attendances[0].date
    mail to: member.email, subject: @title
  end
end
