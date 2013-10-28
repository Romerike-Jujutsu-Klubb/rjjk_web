class PublicRecord < ActiveRecord::Base
  attr_accessible :board_members, :chairman, :contact, :deputies, :registered_on
end
