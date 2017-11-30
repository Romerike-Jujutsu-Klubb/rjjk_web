# frozen_string_literal: true

class UserMessageMailer < ApplicationMailer
  def send_message(um)
    @title = um.title || um.subject
    @user_email = um.user_email || um.user.email
    @email_url =
        if um.email_url.is_a?(String)
          um.email_url
        else
          { only_path: false, email: @user_email && Base64.encode64(@user_email) }
              .merge(um.email_url || { controller: :user_messages, action: :show,
                                       id: um.id, key: um.key })
        end
    @timestamp = um.message_timestamp

    url_key = ERB::Util.url_encode(um.key)
    if (html_body = um.html_body)
      modify_links(html_body, url_key)
    end
    if (plain_body = um.plain_body)
      modify_links(plain_body, url_key)
    end

    mail from: um.from, to: safe_email(um.user), subject: rjjk_prefix(um.subject) do |format|
      if html_body
        format.html do
          render html: html_body.html_safe, layout: 'email' # rubocop: disable Rails/OutputSafety
        end
      end
      format.text { render plain: plain_body, layout: 'email' } if plain_body
    end
  end

  private

  def modify_links(body, url_key)
    add_host_and_port(body)
    add_security_key(body, url_key)
  end

  def add_host_and_port(body)
    url_opts = Rails.application.config.action_mailer.default_url_options
    port = (":#{url_opts[:port]}" if url_opts[:port] && url_opts[:port] != 80)
    body.gsub! %r{href="(/[^"]*)"},
        %(href="#{url_opts[:protocol] || :http}://#{url_opts[:host]}#{port}\\1")
  end

  def add_security_key(body, url_key)
    body.gsub!(%r{href="([^/]*)://([^/]*)([^"?#]*)(?:\?([^"#]+))?(\#[^"]+)?"}) do
      params = "#{"#{Regexp.last_match(4)}&" if Regexp.last_match(4)}key=#{url_key}"
      %(href="#{Regexp.last_match(1)}://#{Regexp.last_match(2)}#{Regexp.last_match(3)}?#{params}) +
          %(#{Regexp.last_match(5)}")
    end
  end
end
