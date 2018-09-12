# frozen_string_literal: true

class NewsPublisher
  def self.send_news
    now = Time.current
    news_item = NewsItem.where('mailed_at IS NULL')
        .where("publication_state IS NULL OR publication_state = 'PUBLISHED'")
        .where('publish_at IS NULL OR publish_at < ?', now)
        .where('expire_at IS NULL OR expire_at > ?', now)
        .where("updated_at IS NULL OR updated_at < timestamp ? - interval '10 minutes'", now)
        .first
    return unless news_item

    Member.active(2.months.from_now).order(:joined_on).each do |m|
      NewsletterMailer.newsletter(news_item, m).store(m, tag: :newsletter)
    end
    news_item.update! mailed_at: now
  end
end
