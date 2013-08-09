class BaiduMailer < ActionMailer::Base
  default from: "#{Rails.env}@jujutsu.no", to: 'uwe@kubosch.no'

  def reject(url)
    @url = url
    mail subject: "[RJJK] #{Rails.env} Rejected BAIDU request"
  end
end
