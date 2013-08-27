# encoding: utf-8
class AttendanceMailer < ActionMailer::Base
  include UserSystem

  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no"
  layout 'email'

  def plan(member)
    @member = member
    @title = 'Planlegging oppmøte'
    @timestamp = Time.now
    @email_url = with_login(member.user, :controller => :attendances, :action => :plan)
    mail to: Rails.env == 'production' ? member.email : %Q{"#{member.name}" <uwe@kubosch.no>},
         subject: '[RJJK] Kommer du?'
  end

  def summary(group_schedule, recipient, attendees, absentees)
    @group_schedule = group_schedule
    @recipient = recipient
    @members = attendees
    @title = "Trening i #{group_schedule.start_at.day_phase}"
    @timestamp = Time.now
    @email_url = with_login(recipient.user, :controller => :attendances, :action => :plan)
    mail to: Rails.env == 'production' ? recipient.email : %Q{"#{recipient.name}" <uwe@kubosch.no>},
         subject: "[RJJK] Trening i <%=@group_schedule.start_at.day_phase%>: #{attendees.size == 0 ? 'Ingen' : attendees.size} deltaker#{'e' if attendees.size > 1} påmeldt"
  end

  def changes(group_schedule, recipient, new_attendees, new_absentees, attendees)
    @group_schedule = group_schedule
    @recipient = recipient
    @new_attendees = new_attendees
    @new_absentees = new_absentees
    @attendees = attendees
    @title = "Trening i #{group_schedule.start_at.day_phase}"
    @timestamp = Time.now
    @email_url = with_login(recipient.user, :controller => :attendances, :action => :plan)
    mail to: Rails.env == 'production' ? recipient.email : %Q{"#{recipient.name}" <uwe@kubosch.no>},
         subject: "[RJJK] Trening i <%=@group_schedule.start_at.day_phase%>: #{"#{new_attendees.size} ny#{'e' if new_attendees.size > 1} deltaker#{'e' if new_attendees.size > 1} påmeldt" if new_attendees.size > 0} #{"#{new_absentees.size} avbud" if new_absentees.any?}"
  end

end
