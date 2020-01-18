# frozen_string_literal: true

class Camp < Event
  HEADER = 'RJJK Leir'

  # TODO(uwe): Consider https://gist.github.com/sj26/5843855
  def self.model_name
    superclass.model_name
  end

  def title
    name.present? ? "#{HEADER}: #{name}" : HEADER
  end
end
