module MailerHelper
  include ApplicationHelper

  def rjjk_prefix
    "[RJJK]#{"[#{Rails.env}]" unless Rails.env.production?}"
  end
end
