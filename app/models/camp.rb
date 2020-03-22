# frozen_string_literal: true

class Camp < Event
  def title
    localized_name.presence || type_name
  end

  def needs_helpers?
    true
  end
end
