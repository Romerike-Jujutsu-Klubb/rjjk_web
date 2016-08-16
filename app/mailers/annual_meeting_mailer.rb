class AnnualMeetingMailer < ActionMailer::Base
  include UserSystem
  include MailerHelper

  default from: noreply_address

  def missing_date(member, year)
    @member = member
    @year = year
    @title = "På tide å sette dato for årsmøte #{year}"

    @email_url = with_login(@member.user, controller: :annual_meetings,
        action: :new, annual_meeting: {})
    mail subject: @title, to: @member.email
  end

  def missing_invitation(annual_meeting, member)
    @annual_meeting = annual_meeting
    @member = member
    @title = "På tide å sende ut innkalling til årsmøte #{annual_meeting.start_at.year}"
    @timestamp = annual_meeting.start_at
    @email_url = with_login(@member.user, controller: :annual_meetings,
        action: :show, id: annual_meeting.id)
    mail subject: @title, to: @member.email
  end
end
