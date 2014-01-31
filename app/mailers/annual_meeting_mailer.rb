class AnnualMeetingMailer < ActionMailer::Base
  include UserSystem
  include MailerHelper
  layout 'email'
  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no"

  def missing_date(member)
    @member = member
    @title = "På tide å sette dato for årsmøte #{Date.today.year}"

    @email_url = with_login(@member.user,
        :controller => :annual_meetings, :action => :new,
        :annual_meeting => {})
    mail subject: rjjk_prefix(@title), to: safe_email(@member)
  end

  def missing_invitation(annual_meeting, member)
    @annual_meeting = annual_meeting
    @member = member
    @title = "På tide å sende ut innkalling til årsmøte #{annual_meeting.start_at.year}"
    @timestamp = annual_meeting.start_at
    mail subject: rjjk_prefix(@title), to: safe_email(@member)
  end
end
