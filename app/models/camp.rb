# frozen_string_literal: true

class Camp < Event
  HEADER = 'RJJK Leir'

  def title
    name.present? ? "#{HEADER}: #{name}" : HEADER
  end
end
