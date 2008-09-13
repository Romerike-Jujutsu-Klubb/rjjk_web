class NewsItem < ActiveRecord::Base
  include UserSystem
  
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  
  validates_length_of :title, :maximum => 64
  
  def before_validation
    self.created_by ||= current_user.id
  end
  
end
