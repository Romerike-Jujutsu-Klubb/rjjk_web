# frozen_string_literal: true

class Camp < Event
  HEADER = 'RJJK Leir'

  def title
    localized_name.presence || HEADER
  end

  def needs_helpers?
    true
  end
end
