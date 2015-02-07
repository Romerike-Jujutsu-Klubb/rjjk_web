# encoding: utf-8
module UserSystem
  ADMIN_ROLE = 'ADMIN'

  CONFIG = {
      # Source address for user emails
      email_from: 'webmaster@jujutsu.no',

      # Destination email for system errors
      admin_email: 'webmaster@jujutsu.no',

      # Sent in emails to users
      app_url: 'http://jujutsu.no/',

      # Sent in emails to users
      app_name: 'RJJK',

      # Email charset
      mail_charset: 'utf-8',

      # Security token lifetime in hours
      security_token_life_hours: 24 * 7,
      autologin_token_life_hours: 24 * 365,
  }

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
    return true if current_user.admin?
    access_denied('Du må være administrator for å se denne siden.')
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
    redirect_to controller: :user, action: :login, id: nil
  end

  def login_from_cookie
    if (token = cookies[:token])
      logger.info "Found login cookie: #{token}"
      self.current_user = User.authenticate_by_token(token)
    end
    current_user
  end

  def login_from_params
    if (token = params[:key]) && (self.current_user = User.authenticate_by_token(token))
      params.delete 'key'
    end
    current_user
  end

  def self.with_login(user = current_user, options)
    options.merge key: user.generate_security_token, only_path: false
  end

  def with_login(user = current_user, options)
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
    return true if login_from_params
    if session[:user_id]
      self.current_user = User.find_by_id(session[:user_id])
    end
    login_from_cookie unless current_user
    true
  end

  def authenticated_user?
    !!current_user
  end

  def admin?
    current_user.try(:admin?)
  end

  def technical_committy?
    current_user.try(:technical_committy?)
  end

  def current_user
    Thread.current[:user]
  end

  def current_user=(user)
    session[:user_id] = (user && user.id) if defined?(session)
    Thread.current[:user] = user
  end

end
