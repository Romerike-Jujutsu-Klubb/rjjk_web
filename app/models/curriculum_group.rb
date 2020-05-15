# frozen_string_literal: true

class CurriculumGroup < ApplicationRecord
  acts_as_list scope: :martial_art_id

  belongs_to :martial_art

  has_many :practice_groups, dependent: :restrict_with_error, inverse_of: :curriculum_group,
      class_name: :Group # FIXME(uwe): Remove this line after renaming Group => PracticeGroup
  has_many :ranks, -> { order(:position) }, dependent: :destroy, inverse_of: :curriculum_group

  before_validation { |r| r.color = nil if r.color.blank? }

  validates :from_age, :martial_art, :name, :to_age, presence: true

  def full_name
    "#{"#{martial_art.name} " if martial_art_id != MartialArt::KWR_ID}#{name}"
  end

  def to_s
    full_name
  end

  def contains_age(age)
    return false if age.nil?

    age >= from_age && age <= to_age
  end
end
