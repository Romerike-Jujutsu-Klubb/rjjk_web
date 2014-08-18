class Rank < ActiveRecord::Base
  include Comparable

  belongs_to :martial_art
  belongs_to :group
  has_many :applications, -> { where('system <> ?', 'Kata') },
      class_name: TechniqueApplication.name
  has_many :basic_techniques, dependent: :nullify
  has_many :embus, dependent: :destroy
  has_many :graduates, dependent: :destroy
  has_many :katas, -> { where 'system = ?', 'Kata' },
      class_name: TechniqueApplication.name
  has_many :technique_applications, dependent: :nullify

  scope :kwr, -> { where(martial_art_id: MartialArt.kwr.first.try(:id)) }

  validates_presence_of :position, :standard_months, :group, :group_id,
      :martial_art, :martial_art_id
  validates_uniqueness_of :position, scope: :martial_art_id

  def minimum_age
    group.from_age + (group.ranks.select { |r| r.position <= self.position }[1..-1].
        inject(0.0) { |s, r| s + r.standard_months.to_f } / 12.0).to_i
  end

  def minimum_attendances
    (group.trainings_in_period(standard_months.months.ago.to_date..Date.today) *
        0.5).round
  end

  def label
    "#{name} #{colour}"
  end

  def kwr?
    martial_art.kwr?
  end

  def <=>(other)
    return 1 unless other
    return kwr? ? 1 : -1 if other.kwr? != kwr?
    position <=> other.position
  end
end
