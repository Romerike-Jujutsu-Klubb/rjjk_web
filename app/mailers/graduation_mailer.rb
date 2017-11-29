# frozen_string_literal: true

class GraduationMailer < ApplicationMailer
  def missing_graduation(instructor, group, suggested_date)
    @instructor = instructor
    @group = group
    @title = 'Disse gruppene mangler gradering'

    @email_url = { controller: :graduations, action: :new, graduation: {
      group_id: @group.id, held_on: suggested_date, group_notification: true
    } }
    mail subject: @title, to: @instructor.email
  end

  def overdue_graduates(members)
    @members = members
    @title = 'Medlemmer klare for gradering'
    @timestamp = Time.current
    mail to: 'uwe@kubosch.no', subject: 'Disse medlemmene mangler gradering'
  end

  def group_date_info(graduation, member)
    @graduation = graduation
    @member = member
    mail subject: "Gradering for #{@graduation.group.name} #{@graduation.held_on}"
  end

  def self.missing_censors(graduation, instructor)
    @graduation = graduation
    @instructor = instructor
    @title = 'Denne graderingen mangler eksaminator'
    @email_url = graduation_url(@graduation)

    mail subject: @title, to: @instructor.email
  end

  def invite_censor(censor)
    @censor = censor
    @title = "Invitasjon til å være #{@censor.role_name}"
    @timestamp = censor.graduation.held_on
    @email_url = { controller: :censors, action: :show, id: @censor.id }
    @confirm_url = { controller: :censors, action: :confirm, id: @censor.id }
    @decline_url = { controller: :censors, action: :decline, id: @censor.id }
    mail to: censor.member.email, subject: @title
  end

  def lock_reminder(censor)
    @censor = censor
    @title = 'Bekrefte graderingsoppsett'
    @timestamp = censor.graduation.held_on
    mail to: censor.member.email, subject: @title
  end

  def invite_graduate(graduate)
    @graduate = graduate
    @title = 'Invitasjon til gradering'
    @timestamp = graduate.graduation.held_on
    # @email_url = { controller: :censors, action: :show, id: @censor.id }
    @confirm_url = { controller: :graduates, action: :confirm, id: @graduate.id }
    @decline_url = { controller: :graduates, action: :decline, id: @graduate.id }
    mail to: graduate.member.email, subject: @title
  end

  def send_shopping_list(graduation, appointment)
    @graduation = graduation
    @appointment = appointment
    mail subject:
        "Liste over belter for gradering for #{graduation.group.name} #{graduation.held_on}"
  end

  def missing_approval(censor)
    @censor = censor
    @title = 'Bekrefte gradering'
    @timestamp = @censor.graduation.held_on
    @email_url = { controller: :graduations, action: :edit, id: @censor.graduation_id }
    mail to: censor.member.email, subject: @title
  end

  def congratulate_graduate(graduate)
    @graduate = graduate
    mail to: graduate.member, subject: 'Gratulerer med bestått gradering!'
  end
end
