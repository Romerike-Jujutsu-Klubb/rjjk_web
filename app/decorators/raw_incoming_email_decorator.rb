class RawIncomingEmailDecorator < Draper::Decorator
  delegate_all

  def mail
    @mail ||= Mail.read_from_string(content)
  end

end
