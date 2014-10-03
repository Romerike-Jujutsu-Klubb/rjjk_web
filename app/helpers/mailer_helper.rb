module MailerHelper
  include ApplicationHelper

  def rjjk_prefix(subject=nil)
    "[RJJK]#{"[#{Rails.env}]" unless Rails.env.production?} #{subject}".strip
  end

  def safe_email(member)
    if Rails.env.production?
      member.emails
    else
      %Q{"#{member.name}" <uwe@kubosch.no>}
    end
  end

end
