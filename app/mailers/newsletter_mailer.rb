# frozen_string_literal: true

class NewsletterMailer < ApplicationMailer
  default from: if Rails.env.production?
                  '"Romerike Jujutsu Klubb" <post@jujutsu.no>'
                else
                  "#{Rails.env}@jujutsu.no"
                end

  def newsletter(news_item, member)
    @news_item = news_item
    @user_email = member.user&.email
    # @timestamp = @news_item.updated_at.to_date
    @email_url = { controller: :news, action: :show, id: @news_item.id }
    mail to: member.email, subject: @news_item.title
  end
end
