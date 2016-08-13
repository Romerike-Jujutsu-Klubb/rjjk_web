class GraduationMailer < ActionMailer::Base
  include UserSystem
  include MailerHelper
  layout 'email'
  default from: Rails.env == 'production' ? 'noreply@jujutsu.no' : "#{Rails.env}@jujutsu.no"

  def missing_graduation(instructor, group, suggested_date)
    @instructor = instructor
    @group = group
    @title = 'Disse gruppene mangler gradering'

    @email_url = with_login(@instructor.user,
        controller: :graduations, action: :new,
        graduation: { group_id: @group.id, held_on: suggested_date })
    mail subject: rjjk_prefix(@title), to: safe_email(@instructor)
  end

  def overdue_graduates(members)
    @members = members
    @title = 'Medlemmer klare for gradering'
    @timestamp = Time.now
    mail to: 'uwe@kubosch.no', subject: rjjk_prefix('Disse medlemmene mangler gradering')
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
    mail to: safe_email(censor.member), subject: rjjk_prefix(@title)
  end

  def missing_approval(censor)
    @censor = censor
    @title = 'Bekrefte gradering'
    @timestamp = Time.now
    @email_url = with_login(@censor.member.user,
        controller: :graduations, action: :edit,
        id: @censor.graduation_id)
    mail to: safe_email(censor.member), subject: rjjk_prefix(@title)
  end

  def member_info_reminder
    mail to: 'to@example.org'
  end
end
