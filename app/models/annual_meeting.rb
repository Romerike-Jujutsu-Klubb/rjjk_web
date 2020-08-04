# frozen_string_literal: true

class AnnualMeeting < Event
  has_many :elections, dependent: :destroy

  before_validation do
    self.name = '' if name.nil?
  end

  validate do
    if id && start_at &&
        self.class.exists?(['id <> ? AND EXTRACT(YEAR FROM start_at) = ?', id, start_at.year])
      errors.add(:start_at, 'kan bare ha et årsmøte per år.')
    end
  end

  def self.current_board
    where('start_at <= ?', Time.current).order(:start_at).last.elections.on_the_board
        .includes(:member)
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

  def self.board_emails
    board_contacts.pluck(:email)
  end

  def self.board_contacts
    [*current_board, Role[:Hovedinstruktør, return_record: true]].map(&:elected_contact)
  end

  def public?
    false
  end
end
