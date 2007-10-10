class Graduate < ActiveRecord::Base
  belongs_to :graduation
  belongs_to :member
  belongs_to :rank
end
