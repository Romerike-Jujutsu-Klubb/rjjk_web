# frozen_string_literal: true

class InternalEvent < Event
  def title
    typed_title
  end

  def public?
    false
  end
end
