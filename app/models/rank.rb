# frozen_string_literal: true

class Rank < ApplicationRecord
  include Comparable

  UNRANKED = new(position: -99, standard_months: 0, name: 'Ugradert', colour: 'Hvitt',
                 martial_art_id: MartialArt::KWR_ID)
  SHODAN_POSITION = 15

  belongs_to :martial_art
  belongs_to :group
  has_many :applications, -> { where('system <> ?', TechniqueApplication::System::KATA) },
      class_name: TechniqueApplication.name
  has_many :basic_techniques, dependent: :nullify
  has_many :embus, dependent: :destroy
  has_many :graduates, dependent: :destroy
  has_many :katas, -> { where 'system = ?', TechniqueApplication::System::KATA },
      class_name: TechniqueApplication.name
  has_many :members, through: :graduates
  has_many :technique_applications, dependent: :nullify

  scope :kwr, -> { where(martial_art_id: MartialArt.kwr.first.try(:id)) }

  validates :position, :standard_months, :group, :group_id,
      :martial_art, :martial_art_id, presence: true
  validates :position, uniqueness: { scope: :martial_art_id }

  def minimum_age
    group.from_age + (group.ranks.select { |r| r.position <= position }[0..-1]
        .inject(0.0) { |s, r| s + r.standard_months.to_f } / 12.0).to_i
  end

  def expected_attendances
    standard_months * (group.from_age < 10 ? 20 : 40) / 6
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
end
