# frozen_string_literal: true

class InstructorMeeting < Event
  HEADER = 'Instruktørsamling'

  def title
    name.present? ? "#{HEADER}: #{name}" : HEADER
  end

  def public?
    false
  end
end
