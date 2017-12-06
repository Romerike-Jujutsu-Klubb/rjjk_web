# frozen_string_literal: true

module UserSystem
  SESSION_KEY = :user_id
  COOKIE_NAME = :"user_id_#{Rails.env}"
  ADMIN_ROLE = 'ADMIN'

  CONFIG = {
    # Source address for user emails
    email_from: 'webmaster@jujutsu.no',

    # Destination email for system errors
    admin_email: 'webmaster@jujutsu.no',

    # Sent in emails to users
    app_url: 'https://jujutsu.no/',

    # Sent in emails to users
    app_name: 'RJJK',

    # Email charset
    mail_charset: 'utf-8',

    # Security token lifetime in hours
    security_token_life_hours: 24 * 7,
    autologin_token_life_hours: 24 * 365,
  }.freeze

  def self.with_login(user = current_user, options)
    options.merge key: user.generate_security_token, only_path: false
  end

  protected

  #   before_filter :authenticate_user
  def authenticate_user
    return true if authenticated_user?
    access_denied
    false
  end

  #   before_filter :admin_required
  def admin_required
    return false unless authenticate_user
    return true if admin?
    access_denied('Du må være administrator for å se denne siden.')
  end

  #   before_filter :instructor_required
  def instructor_required
    return false unless authenticate_user
    return true if instructor?
    access_denied('Du må være instruktør for å se denne siden.')
  end

  #   before_filter :technical_committy_required
  def technical_committy_required
    return false unless authenticate_user
    return true if current_user.technical_committy?
    access_denied('Du må være i teknisk komite for å se denne siden.')
  end

  # overwrite if you want to have special behavior in case the user is not authorized
  # to access the current operation.
  # The default action is to redirect to the login screen.
  # Example use :
  # a popup window might just close itself for instance
  def access_denied(message = 'Access denied!')
    flash.alert = message
    flash.notice = message
    store_detour(params)
    redirect_to login_path
  end

  def store_cookie(user = current_user)
    cookies.encrypted[COOKIE_NAME] = { value: user.id, expires: 30.days.from_now }
        .merge(COOKIE_SCOPE)
  end

  def login_from_cookie
    if (user_id = cookies.encrypted[COOKIE_NAME])
      logger.info "Found login cookie: #{user_id}"
      self.session_user = User.find_by(id: user_id)
    end
    current_user
  end

  def clear_cookie
    cookies.delete(COOKIE_NAME, COOKIE_SCOPE)
  end

  def login_from_params
    if (token = params[:key])
      if (self.session_user = User.authenticate_by_token(token) ||
            (um = UserMessage.includes(:user).find_by(key: CGI.unescape(token)))&.user)
        params.delete(:key)
        store_cookie(current_user)
        um&.update!(read_at: Time.current) if um && !um.read_at
        logger.info "User #{current_user.name} (#{current_user.id}) logged in by key."
      end

    end
    current_user
  end

  def with_login(user, options)
    UserSystem.with_login(user, options)
  end

  def clear_user
    Thread.current[:user] = nil
  end

  def user?
    authenticated_user?
  end

  def member?
    !!current_user.try(:member)
  end

  def store_current_user_in_thread
    return if login_from_params
    return if session_user? && (self.current_user = session_user)
    login_from_cookie
  end

  def authenticated_user?
    !!current_user
  end

  def admin?
    current_user.try(:admin?)
  end

  def instructor?
    admin? || current_user.try(:instructor?)
  end

  def technical_committy?
    current_user.try(:technical_committy?)
  end

  def current_user
    Thread.current[:user]
  end

  def current_user=(user)
    Thread.current[:user] = user
  end

  def session_user?
    session[SESSION_KEY]
  end

  def session_user
    User.find_by(id: session[SESSION_KEY])
  end

  def session_user=(user)
    session[SESSION_KEY] = (user&.id)
    self.current_user = user
  end

  def clear_session
    session.delete(SESSION_KEY)
  end
end
