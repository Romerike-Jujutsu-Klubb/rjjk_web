class ApplicationMailer < ActionMailer::Base
  def mail(headers = {}, &block)
    headers['X-Title'] = @title if @title
    headers['X-User-Email'] = @user_email if @user_email
    headers['X-Message-Timestamp'] = @timestamp if @timestamp
    headers['X-Email-URL'] = JSON.dump(@email_url) if @email_url
    super(headers, &block)
  end
end
