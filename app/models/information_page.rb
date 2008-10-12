class InformationPage < ActiveRecord::Base
  acts_as_tree :order => :title
  acts_as_list :scope => :parent_id
end
