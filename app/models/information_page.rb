class InformationPage < ActiveRecord::Base
  acts_as_tree :order => :title
  acts_as_list :scope => :parent_id

  before_validation do
    body.try(:strip!)
  end

  def visible?
    !hidden
  end
  
end
