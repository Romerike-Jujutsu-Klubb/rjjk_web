class InformationPageMailer < ActionMailer::Base
  include UserSystem
  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no"
  layout 'email'

  def notify_outdated_pages(recipients, pages)
    @recipients = recipients
    @pages = pages
    @timestamp = Time.now
    mail to: Rails.env == 'production' ?
        recipients.map(&:email) : %Q{"#{recipients.map(&:first_name).join(' ')}" <uwe@kubosch.no>},
         subject: '[RJJK] Oppdatering av informasjonssider'
  end

  def send_weekly_page(member, page)
    @member = member
    @page = page
    @email_url = with_login(member.user, :controller => :info, :action => :show, :id => page.id)
    @title = page.title
    @timestamp = @page.revised_at
    mail from: Rails.env == 'production' ? 'post@jujutsu.no' : "#{Rails.env}@jujutsu.no",
         to: Rails.env == 'production' ? member.email : %Q{"#{member.name}" <uwe@kubosch.no>},
         subject: "[RJJK] #{@page.title}"
  end
end
