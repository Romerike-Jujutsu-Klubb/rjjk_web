# frozen_string_literal: true
class Election < ActiveRecord::Base
  belongs_to :annual_meeting
  belongs_to :member
  belongs_to :role

  validates :member_id, :role_id, presence: true

  scope :current, -> {
    includes(:annual_meeting).references(:annual_meetings)
        .where(<<~SQL, now: Time.current)
        annual_meetings.start_at <= :now
          AND (annual_meetings.start_at + interval '1 year' * years + interval '1 month') >= :now
          AND NOT EXISTS (
            SELECT 1 FROM elections e2 JOIN annual_meetings am2 ON am2.id = e2.annual_meeting_id
            WHERE e2.role_id = elections.role_id
              AND am2.start_at > annual_meetings.start_at
              AND am2.start_at <= :now
          )
        SQL
  }

  scope :on_the_board, -> {
    includes(:role).where.not(roles: {years_on_the_board: nil})
  }

  def from
    annual_meeting.start_at.to_date
  end

  def to
    annual_meeting.next.start_at.to_date
  end

  def elected_name
    if guardian_index
      "#{member.guardians[guardian_index][:name]} (for #{member.name})"
    else
      member.name
    end
  end

  def elected_contact
    if guardian_index
      member.guardians[guardian_index]
    else
      {name: member.name, email: member.email || member.emails.first}
    end
  end
end
