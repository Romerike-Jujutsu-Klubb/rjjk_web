# frozen_string_literal: true
class AnnualMeeting < ActiveRecord::Base
  has_many :elections, dependent: :destroy

  validate do
    if id && start_at && self.class
          .where('id <> ? AND EXTRACT(YEAR FROM start_at) = ?', id, start_at.year)
          .exists?
      errors.add(:start_at, 'kan bare ha et årsmøte per år.')
    end
  end

  def next
    @_next_ ||= self.class.where('start_at > ?', start_at).order(:start_at).first
  end

  def date
    start_at.try(:to_date)
  end

  def board_members
    elections.includes(:role).references(:roles)
        .where('roles.years_on_the_board IS NOT NULL').to_a.map(&:member)
  end
end
