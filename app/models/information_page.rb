class InformationPage < ActiveRecord::Base
  acts_as_tree :order => :title
  acts_as_list :scope => :parent_id

  before_validation do
    body.try(:strip!)
  end

  validates_uniqueness_of :title, :scope => :parent_id, :case_sensitive => false

  def visible?
    !hidden
  end

end
