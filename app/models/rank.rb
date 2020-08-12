# frozen_string_literal: true

class Rank < ApplicationRecord
  include Comparable

  KEI_WA_RYU_CHARACTERS = '啓和流柔術'
  UNRANKED = new(position: -99, standard_months: 0, name: 'Ugradert', colour: 'Hvitt')
  SHODAN_POSITION = 15

  # belongs_to :martial_art
  belongs_to :curriculum_group

  has_many :applications, -> { where('system <> ?', TechniqueApplication::System::KATA) },
      class_name: TechniqueApplication.name
  has_many :basic_techniques, dependent: :nullify
  has_many :embus, dependent: :destroy
  has_many :graduates, dependent: :destroy
  has_many :katas, -> { where 'system = ?', TechniqueApplication::System::KATA },
      class_name: TechniqueApplication.name
  has_many :rank_articles, dependent: :destroy
  has_many :technique_applications, dependent: :nullify

  has_many :members, through: :graduates

  scope :kwr,
      -> {
        includes(:curriculum_group).where(curriculum_groups: { martial_art_id: MartialArt.kwr.first&.id })
      }

  acts_as_list scope: :curriculum_group_id

  validates :name, length: { maximum: 16 }
  validates :position, :standard_months, :martial_art, presence: true

  delegate :martial_art, :martial_art_id, to: :curriculum_group, allow_nil: true

  def minimum_age
    curriculum_group.from_age + (curriculum_group.ranks.select { |r| r.position <= position }[0..]
        .inject(0.0) { |s, r| s + r.standard_months.to_f } / 12.0).to_i
  end

  def expected_attendances
    standard_months * (curriculum_group.from_age < 10 ? 20 : 40) / 6
  end

  def minimum_attendances
    expected_attendances / 2
  end

  def label
    "#{name} #{colour}#{" #{decoration}" if decoration.present?}"
  end

  def kwr?
    martial_art_id == MartialArt::KWR_ID
  end

  def <=>(other)
    return 1 if other.nil? || other == UNRANKED
    return nil unless other.is_a? Rank
    return kwr? ? 1 : -1 if other.martial_art_id != martial_art_id

    position <=> other.position
  end

  def to_s
    name
  end
end
