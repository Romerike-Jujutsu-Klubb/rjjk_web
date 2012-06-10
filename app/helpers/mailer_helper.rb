module MailerHelper
  def textify(s)
    RedCloth.new(s.strip.force_encoding('UTF-8')).to_plain
  end

end
