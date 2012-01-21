class Rank < ActiveRecord::Base
  belongs_to :martial_art
  belongs_to :group

  validates_presence_of :position, :standard_months, :group, :group_id, :martial_art, :martial_art_id
  validates_uniqueness_of :position, :scope => :martial_art_id

  def minimum_age
    group.from_age + (group.ranks.select{|r| r.position < self.position}.inject(0.0){|s, r| s + r.standard_months.to_f} / 12.0).to_i
  end

  def minimum_attendances
    (group.trainings_in_period(standard_months.months.ago.to_date..Date.today) * 0.5).round
  end

end
