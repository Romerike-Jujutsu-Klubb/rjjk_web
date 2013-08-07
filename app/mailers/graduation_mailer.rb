class GraduationMailer < ActionMailer::Base
  layout 'email'
  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no",
          to: 'uwe@kubosch.no'

  def missing_graduations(groups)
    @groups = groups
    mail subject: "Disse gruppene mangler gradering"
  end

  def overdue_graduates(members)
    @members = members
    mail subject: "Disse medlemmene mangler gradering"
  end

  def date_info_reminder
    mail to: "to@example.org"
  end

  def lock_reminder
    mail to: "to@example.org"
  end

  def member_info_reminder
    mail to: "to@example.org"
  end
end
