# frozen_string_literal: true
class InformationPageMailer < ApplicationMailer
  def notify_outdated_pages(member, pages)
    @member = member
    @pages = pages
    @title = 'Oppdatering av informasjonssider'
    @timestamp = Time.now
    mail to: member.email, subject: @title
  end

  def send_weekly_page(member, page)
    @member = member
    @page = page
    @email_url = { controller: :info, action: :show, id: page.id }
    @title = "Til info: #{page.title}"
    mail from: Rails.env == 'production' ? 'post@jujutsu.no' : "#{Rails.env}@jujutsu.no",
        to: member.email, subject: @title
  end
end
