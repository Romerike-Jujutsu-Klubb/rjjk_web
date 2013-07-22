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

  def summary(recipients, members)
    @members = members
    @title = 'Trening i kveld'
    @timestamp = Time.now
    @email_url = nil
    mail to: Rails.env == 'production' ?
        recipients.map(&:email) : %Q{"#{recipients.map(&:first_name).join(' ')}" <uwe@kubosch.no>},
         subject: "[RJJK] Trening i kveld: #{members.size} deltaker#{'e' if members.size > 1} påmeldt"
  end

  def changes(recipients, attendees, absentees)
    @attendees = attendees
    @absentees = absentees
    @title = 'Trening i kveld'
    @timestamp = Time.now
    @email_url = nil
    mail to: Rails.env == 'production' ?
        recipients.map(&:email) : %Q{"#{recipients.map(&:first_name).join(' ')}" <uwe@kubosch.no>},
         subject: "[RJJK] Trening i kveld: #{attendees.size == 0 ? 'Ingen' : attendees.size} deltaker#{'e' if attendees.size != 1} påmeldt"
  end

end
