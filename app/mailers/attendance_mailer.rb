# encoding: utf-8
class AttendanceMailer < ActionMailer::Base
  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no"
  layout 'email'

  def plan(member)
    @member = member
    @title = 'Ditt oppmøte'
    @timestamp = Time.now
    key = member.user.generate_security_token
    @email_url = {:controller => :attendances, :action => :plan, :id => member.user.id, :key => key}
    mail to: Rails.env == 'production' ? member.email : %Q{"#{member.name}" <uwe@kubosch.no>},
         subject: '[RJJK] Kommer du?'
  end
end
