# frozen_string_literal: true

class TimeOfDay
  def day_phase
    self < self.class.new(17, 0) ? 'dag' : 'kveld'
  end
end
