class NewsItem < ActiveRecord::Base
  validates_length_of :title, :maximum => 32
end
