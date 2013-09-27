class GraduationMailer < ActionMailer::Base
  include UserSystem
  layout 'email'
  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no"

  def missing_graduation(instructor, group)
    @instructor = instructor
    @group = group
    @title = 'Disse gruppene mangler gradering'

    month_start = Date.commercial(Date.today.year, Date.today.mon >= 7 ? 12 : 6, 1)
    suggested_date = month_start + (7 - month_start.wday) + @group.group_schedules.first.weekday

    @email_url = with_login(@instructor.user,
                            :controller => :graduations, :action => :new,
                            :graduation => {:group_id => @group.id, :held_on => suggested_date})
    mail subject: @title,
         to: Rails.env == 'production' ? @instructor.email : "\"#{@instructor.name}\" <uwe@kubosch.no>"
  end

  def overdue_graduates(members)
    @members = members
    mail subject: 'Disse medlemmene mangler gradering'
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
