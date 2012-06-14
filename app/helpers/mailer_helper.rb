module MailerHelper
  def textify(s)
    return '' if s.blank?
    RedCloth.new(s.strip.force_encoding('UTF-8')).to_plain
  end

end
