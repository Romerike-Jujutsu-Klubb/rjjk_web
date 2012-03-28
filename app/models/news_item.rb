class NewsItem < ActiveRecord::Base
  module PublicationState
    DRAFT = 'DRAFT'
    PUBLISHED = 'PUBLISHED'
    EXPIRED = 'EXPIRED'
  end

  include UserSystem
  
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  
  before_validation do |news_item|
    news_item.created_by ||= current_user.try(:id)
  end

  validates_presence_of :publication_state
  validates_length_of :title, :maximum => 64
  validates_inclusion_of :publication_state, :in => PublicationState.constants
end
