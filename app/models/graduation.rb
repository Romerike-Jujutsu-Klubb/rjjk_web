class Graduation < ActiveRecord::Base
  belongs_to :martial_art
  has_many :graduates
end
