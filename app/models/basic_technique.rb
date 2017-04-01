# frozen_string_literal: true

class BasicTechnique < ActiveRecord::Base
  belongs_to :rank
  belongs_to :waza
  has_many :basic_technique_links, dependent: :destroy

  validates :name, :waza_id, presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
