# frozen_string_literal: true

class InternalEvent < Event
  def public?
    false
  end
end
