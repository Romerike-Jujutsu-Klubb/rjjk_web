module UserSystem
  ADMIN_ROLE = 'ADMIN'
  
  CONFIG = {
    # Source address for user emails
    :email_from => 'uwe@kubosch.no',

    # Destination email for system errors
    :admin_email => 'uwe@kubosch.no',

    # Sent in emails to users
    :app_url => 'http://jujutsu.no/',

    # Sent in emails to users
    :app_name => 'RJJK\'s Nettsted',

    # Email charset
    :mail_charset => 'utf-8',

    # Security token lifetime in hours
    :security_token_life_hours => 24 * 7,
  }

  protected
  
  # authenticate_user filter. add
  #
  #   before_filter :authenticate_user
  #
  def authenticate_user
    return true if authenticated_user?
    session[:return_to] = request.path
    access_denied
    false
  end
  
  #   before_filter :admin_required
  #
  def admin_required
    return false unless authenticate_user
    if authenticated_user? && user.role == ADMIN_ROLE
      return true
    end
    store_location
    access_denied
  end
  
  # overwrite if you want to have special behavior in case the user is not authorized
  # to access the current operation. 
  # the default action is to redirect to the login screen
  # example use :
  # a popup window might just close itself for instance
  def access_denied
    redirect_to :controller => "/user", :action => "login"
  end  
  
  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    session[:return_to] = request.path
  end
  
  def redirect_back_or_default(default)
    if session[:return_to].nil?
      redirect_to default
    else
      redirect_to session[:return_to]
      session[:return_to] = nil
    end
  end
  
  def login_from_cookie
    if token = cookies[:auth_token]
      user_by_token = User.find_by_security_token(token)
      if user_by_token
        self.current_user = User.authenticate_by_token(user_by_token.id, token)
      end
    end
    true
  end
  
  def clear_user
    Thread.current[:user] = nil
  end
  
  def user?
    authenticated_user?
  end

  def store_current_user_in_thread
    if session[:user_id]
      self.current_user = User.find_by_id(session[:user_id])
    end
    true
  end

  def authenticated_user?
    return true if current_user

    if cookie = cookies[:autologin]
      cookie_value = case cookie
        when String # Development
        cookies[:autologin]
        when Hash  # Production
        cookies[:autologin][:value].first
        when Array  # Not sure why this happens in development...
        cookies[:autologin].first
      else
        raise "Unknown cookie class: #{cookie.class}\n#{cookie.inspect}"
      end
      
      token = cookies[:token] && case cookies[:token]
        when String # Development
        cookies[:token]
        when Hash   # Production
        cookies[:token][:value].first
        when Array  # Not sure why this happens in development...
        cookies[:token].first
      else
        raise "Unknown cookie class: #{cookie.class}"
      end
      
      begin
        cookie_user = User.authenticate_by_token(Integer(cookie_value), token)
      rescue ArgumentError => e
        logger.warn e
      end
      
      cookie_user ||= User.authenticate(cookie_value, '')
      if cookie_user
        @current_user = cookie_user
        self.current_user = cookie_user
        return cookie_user
      end
    end
    
    # If not, is the user being authenticated by a token (created by signup/forgot password actions)?
    return false if not params['user']
    id = params['user']['id']
    key = params['key']
    if id and key
      @current_user = User.authenticate_by_token(id, key)
      self.current_user = @current_user
      return true if not @current_user.nil?
    end
    
    # Everything failed
    false
  end
  
  def user
    current_user
  end
  
  def admin?
    current_user && current_user.role == ADMIN_ROLE
  end
  
  def current_user
    Thread.current[:user]
  end
  
  def current_user= user
    session[:user_id] = (user && user.id) if defined?(session)
    Thread.current[:user] = user
  end

end
