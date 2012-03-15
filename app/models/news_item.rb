class NewsItem < ActiveRecord::Base
  include UserSystem
  
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  
  validates_length_of :title, :maximum => 64
  
  before_validation do |news_item|
    news_item.created_by ||= current_user.try(:id)
  end
  
end
