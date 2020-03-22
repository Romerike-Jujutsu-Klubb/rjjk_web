# frozen_string_literal: true

class VoluntaryWork < Event
  def title
    typed_title
  end

  def public?
    false
  end
end
