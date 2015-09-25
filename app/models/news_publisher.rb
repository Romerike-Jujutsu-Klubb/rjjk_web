class NewsPublisher
  def self.send_news
    logger.debug 'Sending news'
    now = Time.now
    news_item = NewsItem.where('mailed_at IS NULL').
        where("publication_state IS NULL OR publication_state = 'PUBLISHED'").
        where('publish_at IS NULL OR publish_at < ?', now).
        where('expire_at IS NULL OR expire_at > ?', now).
        where("updated_at IS NULL OR updated_at < timestamp ? - interval '10 minutes'", now).
        first
    if news_item
      Member.active(2.months.from_now).each do |m|
        NewsletterMailer.newsletter(news_item, m).deliver_now
      end
      news_item.update_attributes! mailed_at: now
    end
    logger.debug 'Sending news...OK'
  rescue
    logger.error 'Execption sending news'
    logger.error $!.message
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
    raise if Rails.env.test?
  end
end
