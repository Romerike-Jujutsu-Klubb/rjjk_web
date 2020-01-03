# frozen_string_literal: true

class VoluntaryWork < Event
  HEADER = 'Dugnad'

  def title
    name.present? ? "#{HEADER}: #{name}" : HEADER
  end

  def public?
    false
  end
end
