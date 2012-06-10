class NewsletterMailer < ActionMailer::Base
  helper :mailer
  default from: "post@jujutsu.no"

  def event_invitation(event, news_item)
    @event = event
    @news_item = news_item

    mail to: "uwe@kubosch.no"
  end

  def newsletter(news_item, user)
    @news_item = news_item
    @user = user

    mail to: "uwe@kubosch.no"
  end

end
