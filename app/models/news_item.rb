class NewsItem < ActiveRecord::Base
  module PublicationState
    DRAFT = 'DRAFT'
    PUBLISHED = 'PUBLISHED'
    EXPIRED = 'EXPIRED'
  end

  extend UserSystem
  include UserSystem

  scope :current, -> { where("(publication_state IS NULL OR publication_state = '#{PublicationState::PUBLISHED}') AND (publish_at IS NULL OR publish_at <= CURRENT_TIMESTAMP) AND (expire_at IS NULL OR expire_at >= CURRENT_TIMESTAMP)") }

  belongs_to :creator, class_name: 'User', foreign_key: :created_by

  before_validation do |news_item|
    news_item.created_by ||= current_user.try(:id)
    news_item.summary = cleanup_html(news_item.summary)
    news_item.body = cleanup_html(news_item.body)
  end

  validates_presence_of :publication_state
  validates_length_of :title, maximum: 64
  validates_inclusion_of :publication_state, in: PublicationState.constants.map(&:to_s)

  def self.front_page_items
    (admin? ? self : current).order('created_at DESC').limit(10).includes(creator: :member).to_a
  end

  def initialize(*args)
    super
    self.publication_state ||= PublicationState::PUBLISHED
  end

  private

  def cleanup_html(field)
    return unless field
    field.gsub(%r{(<td[^>]*>\s*)<p>((?:(?!</td>).)*)</p>(\s*</td>)}, '\1\2\3')
        .gsub(/<table>/, '<table class="table">')
        .gsub(%r{\s*<p>(\s*|&nbsp;)*</p>\s*}, '')
  end
end
