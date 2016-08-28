# frozen_string_literal: true
class GraduationMailer < ApplicationMailer
  def missing_graduation(instructor, group, suggested_date)
    @instructor = instructor
    @group = group
    @title = 'Disse gruppene mangler gradering'

    @email_url = { controller: :graduations, action: :new,
        graduation: { group_id: @group.id, held_on: suggested_date } }
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
    @email_url = { controller: :censors, action: :show, id: @censor.id }
    @confirm_url = { controller: :censors, action: :confirm, id: @censor.id }
    @decline_url = { controller: :censors, action: :decline, id: @censor.id }
    mail to: censor.member.email, subject: @title
  end

  def missing_approval(censor)
    @censor = censor
    @title = 'Bekrefte gradering'
    @timestamp = Time.now
    @email_url = { controller: :graduations, action: :edit, id: @censor.graduation_id }
    mail to: censor.member.email, subject: @title
  end

  def member_info_reminder
    mail to: 'to@example.org'
  end
end
