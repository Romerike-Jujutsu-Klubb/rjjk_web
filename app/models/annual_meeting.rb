# frozen_string_literal: true

class AnnualMeeting < Event
  has_many :elections, dependent: :destroy

  before_validation { self.name = '' if name.nil? }

  def self.current_board
    where('start_at <= ?', Time.current).order(:start_at).last.elections.on_the_board
        .includes(:member)
  end

  def next
    @_next_ ||= self.class.where('start_at > ?', start_at).order(:start_at).first
  end

  def date
    start_at&.to_date
  end

  def board_members
    elections.includes(:role).references(:roles).where.not('roles.years_on_the_board' => nil)
        .to_a.map(&:member)
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
