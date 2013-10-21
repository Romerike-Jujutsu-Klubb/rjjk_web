class GraduationMailer < ActionMailer::Base
  include UserSystem
  include MailerHelper
  layout 'email'
  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no"

  def missing_graduation(instructor, group)
    @instructor = instructor
    @group = group
    @title = 'Disse gruppene mangler gradering'

    month_start = Date.civil(Date.today.year, (Date.today.mon >= 7) ? 12 : 6)
    suggested_date = month_start + (7 - month_start.wday) + @group.group_schedules.first.weekday

    @email_url = with_login(@instructor.user,
                            :controller => :graduations, :action => :new,
                            :graduation => {:group_id => @group.id, :held_on => suggested_date})
    mail subject: rjjk_prefix(@title),
         to: Rails.env == 'production' ? @instructor.email : "\"#{@instructor.name}\" <uwe@kubosch.no>"
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

  def lock_reminder
    mail to: 'to@example.org'
  end

  def member_info_reminder
    mail to: 'to@example.org'
  end
end
