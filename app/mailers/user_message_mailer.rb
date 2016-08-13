class UserMessageMailer < ActionMailer::Base
  include MailerHelper
  default from: 'no-reply@jujutsu.no'

  def send_message(um)
    @title = um.subject
    url_key = ERB::Util.url_encode(um.key)
    @email_link = {:controller => :user_messages, :action => :show,
        :id => um.id, :key => url_key, :only_path => false}
    body = um.body

    # Add security key
    body.gsub! /href="([^"]*)"/, %Q{href="\\1?key=#{url_key}"}

    # Add host and port
    url_opts = Rails.application.config.action_mailer.default_url_options
    body.gsub! /href="(\/[^"]*)"/, %Q{href="#{url_opts[:protocol]}://#{url_opts[:host]}#{":#{url_opts[:port]}" if url_opts[:port] && url_opts[:port] != 80}\\1"}

    mail from: um.from, to: safe_email(um.user), subject: tmss_prefix(@title) do |format|
      format.html { render inline: body, layout: 'email' }
    end
  end

end
