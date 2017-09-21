# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  SESSION_KEY = :user_id
  COOKIE_NAME = :datek_user_id
  COOKIE_DOMAIN = Rails.env.production? ? { domain: :all, tld_length: 2 } : {}

  included do
    if respond_to? :before_action
      before_action :require_login
      around_action :set_locale, if: :current_user
      after_action :clear_user
    end
  end

  private

  def set_locale
    I18n.with_locale(current_user.locale) { yield }
  end

  def clear_user
    self.current_user = nil
  end

  def login_by_token
    key = params[:key]&.strip
    return if key.blank?
    user = User.find_by(security_token: key)
    unless user
      flash.alert = t(:login_link_expired)
      return
    end
    return if user.security_token_stored_at < 1.day.ago
    self.current_user = user
  end

  def login_by_cookie
    if (user_id_cookie = cookies.encrypted[COOKIE_NAME])
      if (user = User.find_by(id: user_id_cookie))
        self.current_user = user
      end
    end
    user
  end

  def login_by_session
    self.current_user = session[SESSION_KEY] && User.find_by(id: session[SESSION_KEY])
  end

  def current_user=(user)
    Thread.current[:user] = user
    return unless respond_to?(:session)
    if user
      session[SESSION_KEY] = user.id
    else
      session.delete(SESSION_KEY)
    end
  end

  def current_user
    unless Thread.current[:user]
      login_by_session || login_by_cookie || login_by_token
      return unless Thread.current[:user]
      store_cookie
    end
    Thread.current[:user]
  end

  def store_cookie
    cookies.encrypted[COOKIE_NAME] = { value: current_user.id, expires: 7.days.from_now }
        .merge(COOKIE_DOMAIN)
  end

  def clear_cookie
    cookies.delete(COOKIE_NAME, COOKIE_DOMAIN)
  end

  def require_login
    redirect_to login_path unless current_user
  end
end
