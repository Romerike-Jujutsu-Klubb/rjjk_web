class NewsItem < ActiveRecord::Base
  module PublicationState
    DRAFT = 'DRAFT'
    PUBLISHED = 'PUBLISHED'
    EXPIRED = 'EXPIRED'
  end

  include UserSystem

  scope :current, where("(publication_state IS NULL OR publication_state = '#{PublicationState::PUBLISHED}') AND (publish_at IS NULL OR publish_at <= CURRENT_TIMESTAMP) AND (expire_at IS NULL OR expire_at >= CURRENT_TIMESTAMP)")

  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  
  before_validation do |news_item|
    news_item.created_by ||= current_user.try(:id)
    if news_item.body
      news_item.body.gsub! /(<td[^>]*>\s*)<p>((?:(?!<\/td>).)*)<\/p>(\s*<\/td>)/, '\1\2\3'
      news_item.body.gsub! /<table>/, '<table class="table">'
    end
  end

  validates_presence_of :publication_state
  validates_length_of :title, :maximum => 64
  validates_inclusion_of :publication_state, :in => PublicationState.constants.map(&:to_s)

  def self.front_page_items
    current.order('created_at DESC').limit(10).includes(:creator => :member).all
  end

  def initialize(*args)
    super
    self.publication_state ||= PublicationState::PUBLISHED
  end

end
