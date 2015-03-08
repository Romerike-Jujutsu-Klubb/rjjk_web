class Election < ActiveRecord::Base
  belongs_to :annual_meeting
  belongs_to :member
  belongs_to :role

  validates_presence_of :member_id, :role_id

  scope :current, -> { includes(:annual_meeting).references(:annual_meetings).
      where("annual_meetings.start_at IS NULL OR (annual_meetings.start_at <= ? AND (annual_meetings.start_at + interval '1 year' * years + interval '1 month') >= ? AND NOT EXISTS (SELECT e2.id FROM elections e2 JOIN annual_meetings am2 ON am2.id = e2.annual_meeting_id WHERE e2.role_id = elections.role_id AND am2.start_at > annual_meetings.start_at AND am2.start_at <= ?))",
          *([Time.now]*3)) }

  def from
    annual_meeting.start_at.to_date
  end

  def to
    annual_meeting.next.start_at.to_date
  end

  def elected_name
    if guardian
      "#{member.guardians[guardian][:name]} (for #{member.name})"
    else
      member.name
    end
  end
end
