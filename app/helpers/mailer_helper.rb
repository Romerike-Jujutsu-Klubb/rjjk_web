module MailerHelper
  include ApplicationHelper

  def rjjk_prefix(subject=nil)
    "[RJJK]#{"[#{Rails.env}]" unless Rails.env.production?} #{subject}".strip
  end

  def safe_email(member)
    %Q{"#{member.name}" <#{Rails.env == 'production' ? member.email : 'uwe@kubosch.no'}>}
  end

end
