# frozen_string_literal: true
class RawIncomingEmailDecorator < SimpleDelegator
  def mail
    @mail ||= Mail.read_from_string(content)
  end
end
