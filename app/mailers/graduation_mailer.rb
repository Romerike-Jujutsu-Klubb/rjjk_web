class GraduationMailer < ActionMailer::Base
  include UserSystem
  include MailerHelper

  default from: noreply_address

  def missing_graduation(instructor, group, suggested_date)
    @instructor = instructor
    @group = group
    @title = 'Disse gruppene mangler gradering'

    @email_url = with_login(@instructor.user,
        controller: :graduations, action: :new,
        graduation: { group_id: @group.id, held_on: suggested_date })
    mail subject: @title, to: @instructor.email
  end

  def overdue_graduates(members)
    @members = members
    @title = 'Medlemmer klare for gradering'
    @timestamp = Time.now
    mail to: 'uwe@kubosch.no', subject: 'Disse medlemmene mangler gradering'
  end

  def date_info_reminder
    mail to: 'to@example.org'
  end

  def invite_censor(censor)
    @censor = censor
    @title = 'Invitasjon til å være sensor'
    @timestamp = censor.graduation.held_on
    @email_url = with_login(@censor.member.user, controller: :censors, action: :show, id: @censor.id)
    @confirm_url = with_login(@censor.member.user, controller: :censors, action: :confirm, id: @censor.id)
    @decline_url = with_login(@censor.member.user, controller: :censors, action: :decline, id: @censor.id)
    mail to: censor.member.email, subject: @title
  end

  def missing_approval(censor)
    @censor = censor
    @title = 'Bekrefte gradering'
    @timestamp = Time.now
    @email_url = with_login(@censor.member.user,
        controller: :graduations, action: :edit,
        id: @censor.graduation_id)
    mail to: censor.member.email, subject: @title
  end

  def member_info_reminder
    mail to: 'to@example.org'
  end
end
