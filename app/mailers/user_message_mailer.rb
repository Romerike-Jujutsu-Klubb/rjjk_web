class UserMessageMailer < ActionMailer::Base
  include MailerHelper
  default from: 'no-reply@jujutsu.no'

  def send_message(um)
    @title = um.subject
    url_key = ERB::Util.url_encode(um.key)
    @email_url = { controller: :user_messages, action: :show,
        id: um.id, key: url_key, only_path: false }

    if (html_body = um.html_body)
      modify_links(html_body, url_key)
    end
    if (plain_body = um.plain_body)
      modify_links(plain_body, url_key)
    end

    mail from: um.from, to: safe_email(um.user), subject: rjjk_prefix(@title) do |format|
      format.html { render html: html_body, layout: 'email' } if html_body
      format.text { render text: plain_body, layout: 'email' } if plain_body
    end
  end

  private

  def modify_links(body, url_key)
    # Add security key
    body.gsub!(/href="([^"]*)"/, %(href="\\1?key=#{url_key}"))
    # Add host and port
    url_opts = Rails.application.config.action_mailer.default_url_options
    body.gsub! %r{href="(/[^"]*)"}, %(href="#{url_opts[:protocol]}://#{url_opts[:host]}#{":#{url_opts[:port]}" if url_opts[:port] && url_opts[:port] != 80}\\1")
  end
end
