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
end
