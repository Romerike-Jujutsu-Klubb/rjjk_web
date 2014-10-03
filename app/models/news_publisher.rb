class NewsPublisher
  def self.send_news
    logger.debug 'Sending news'
    news_item = NewsItem.where('mailed_at IS NULL').
        where("publication_state IS NULL OR publication_state = 'PUBLISHED'").
        where('publish_at IS NULL OR publish_at < CURRENT_TIMESTAMP').
        where('expire_at IS NULL OR expire_at > CURRENT_TIMESTAMP').
        where("updated_at IS NULL OR updated_at < CURRENT_TIMESTAMP - interval '10' minute").
        first
    if news_item
      Member.active(3.months.from_now).each do |m|
        NewsletterMailer.newsletter(news_item, m).deliver
      end
      news_item.update_attributes! mailed_at: Time.now
    end
    logger.debug 'Sending news...OK'
  rescue
    logger.error 'Execption sending news'
    logger.error $!.message
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end
end
