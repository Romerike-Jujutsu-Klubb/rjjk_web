class InformationPageMailer < ActionMailer::Base
  include UserSystem
  include MailerHelper

  default from: noreply_address

  def notify_outdated_pages(member, pages)
    @member = member
    @pages = pages
    @title = 'Oppdatering av informasjonssider'
    @timestamp = Time.now
    mail to: safe_email(member), subject: rjjk_prefix(@title)
  end

  def send_weekly_page(member, page)
    @member = member
    @page = page
    @email_url = with_login(member.user, controller: :info, action: :show, id: page.id)
    @title = "Til info: #{page.title}"
    mail from: Rails.env == 'production' ? 'post@jujutsu.no' : "#{Rails.env}@jujutsu.no",
        to: safe_email(member), subject: rjjk_prefix(@title)
  end
end
