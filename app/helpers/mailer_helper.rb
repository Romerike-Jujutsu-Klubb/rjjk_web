module MailerHelper
  include ApplicationHelper

  def rjjk_prefix(subject=nil)
    "[RJJK]#{"[#{Rails.env}]" unless Rails.env.production?} #{subject}".strip
  end
end
