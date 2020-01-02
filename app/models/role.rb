# frozen_string_literal: true

class Role < ApplicationRecord
  acts_as_list scope: [:years_on_the_board]

  has_many :appointments, dependent: :restrict_with_exception
  has_many :elections, dependent: :restrict_with_exception

  after_update do
    if saved_change_to_years_on_the_board?
      if years_on_the_board.nil?
        elections.current.each do |a|
          am = a.annual_meeting
          a.destroy
          appointments.create! member_id: a.member_id, from: am.start_at&.to_date,
                               to: am.next&.start_at&.to_date
        end
      else
        appointments.current.each do |a|
          next unless (am = AnnualMeeting.find_by('DATE(start_at) = ?', a.from))

          a.destroy
          elections.create! member_id: a.member_id, annual_meeting_id: am.id, years: years_on_the_board
        end
      end
    end
  end

  scope :by_name, ->(name) { where(name: name) }
  # scope :active, -> (date = Date.current) { where(name: name).first }

  def self.[](name, return_record: false)
    role = by_name(name).first
    return nil unless role

    record = (role.elections.current.first || role.appointments.current.first)
    return record if return_record

    record&.member
  end

  def on_the_board?
    !!years_on_the_board
  end

  def to_s
    "#{name}#{" (#{years_on_the_board} years on the board)" if years_on_the_board}"
  end
end
