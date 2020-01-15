# frozen_string_literal: true

class BasicTechnique < ApplicationRecord
  belongs_to :rank
  belongs_to :waza
  has_many :basic_technique_links, dependent: :destroy

  before_validation { description.strip! }

  validates :name, :waza_id, presence: true
  validate do
    if (maid = rank&.curriculum_group&.martial_art_id)
      query = self.class.joins(rank: :curriculum_group).where('curriculum_groups.martial_art_id': maid)
          .where('LOWER(basic_techniques.name) = ?', name.downcase)
      query = query.where.not('basic_techniques.id': id) if id
      errors.add :name, :taken if query.exists?
    end
  end
end
