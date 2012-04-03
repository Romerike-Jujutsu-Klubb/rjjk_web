class EmbuImage < ActiveRecord::Base
  belongs_to :embu
  belongs_to :image

  validates_uniqueness_of :image_id, :scope => :embu_id
end
