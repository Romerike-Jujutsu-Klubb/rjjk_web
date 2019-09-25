# frozen_string_literal: true

class ExternalEvent < Event
  HEADER = 'Eksternt arrangement'

  def title
    name.present? ? "#{HEADER}: #{name}" : HEADER
  end
end
