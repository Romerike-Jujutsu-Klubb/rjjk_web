# frozen_string_literal: true

class NewsItem < ApplicationRecord
  module PublicationState
    DRAFT = 'DRAFT'
    PUBLISHED = 'PUBLISHED'
    EXPIRED = 'EXPIRED'
  end

  extend UserSystem
  include UserSystem

  scope :current, -> {
    where('publication_state IS NULL OR publication_state = ?',
        PublicationState::PUBLISHED)
        .where('publish_at IS NULL OR publish_at <= CURRENT_TIMESTAMP')
        .where('expire_at IS NULL OR expire_at >= CURRENT_TIMESTAMP')
  }

  # TODO(uwe): Rename to "author"?
  belongs_to :creator, class_name: 'User', foreign_key: :created_by, inverse_of: :news_items
  # ODOT

  has_many :news_item_likes, dependent: :destroy

  before_validation do |news_item|
    news_item.created_by ||= current_user.try(:id)
    news_item.summary = cleanup_html(news_item.summary)
    news_item.body = cleanup_html(news_item.body)
  end

  validates :publication_state, presence: true
  validates :title, length: { maximum: 64, allow_blank: false }
  validates :publication_state, inclusion: { in: PublicationState.constants.map(&:to_s) }

  def self.front_page_items
    (admin? ? self : current).order('COALESCE(publish_at, created_at) DESC').limit(10)
        .includes(creator: :member).to_a
  end

  def initialize(*args)
    super
    self.publication_state ||= PublicationState::PUBLISHED
  end

  def likes_message
    users = news_item_likes.map(&:user).sort_by { |u| u == current_user ? 0 : 1 }
    names = users.map { |u| u == current_user ? 'Du' : u.first_name }
    "#{names[0..-2].join(', ')} #{'og' if names.size > 1} #{names[-1]} liker dette."
  end

  def expired?
    (publication_state == PublicationState::EXPIRED) || (expire_at&.< Time.current)
  end

  private

  def cleanup_html(field)
    return unless field
    field.gsub(%r{(<td[^>]*>\s*)<p>((?:(?!</td>).)*)</p>(\s*</td>)}, '\1\2\3')
        .gsub(/<table>/, '<table class="table">')
        .gsub(%r{\s*<p>(\s*|&nbsp;)*</p>\s*}, '')
  end
end
