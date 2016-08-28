# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  include MailerHelper
  helper :application

  default from: noreply_address

  def mail(headers = {}, &block)
    headers['X-Title'] = @title if @title
    headers['X-User-Email'] = @user_email if @user_email
    headers['X-Message-Timestamp'] = @timestamp if @timestamp
    headers['X-Email-URL'] = JSON.dump(@email_url) if @email_url
    super(headers, &block)
  end
end
