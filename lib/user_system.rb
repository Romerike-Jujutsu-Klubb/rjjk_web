module UserSystem
  ADMIN_ROLE = 'ADMIN'
  
  protected
  
  # authenticate_user filter. add
  #
  #   before_filter :authenticate_user
  #
  def authenticate_user
    return true if authenticated_user?
    session[:return_to] = request.request_uri
    access_denied
    return false 
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
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    if session[:return_to].nil?
      redirect_to default
    else
      redirect_to_url session[:return_to]
      session[:return_to] = nil
    end
  end
  
  def login_from_cookie
    if token = cookies[:auth_token]
      user_by_token = User.find_by_security_token(token)
      if user_by_token
        session['user'] = User.authenticate_by_token(user_by_token.id, token)
      end
    end
    true
  end
  
  def user?
    authenticated_user?
  end
  
  def authenticated_user?
    if session[:user_id]
      @current_user = User.find_by_id(session[:user_id])
      return false if @current_user.nil? 
      return true
    end
    
    if cookie = cookies[:autologin]
      cookie_value = case cookie
        when String: # Development
        cookies[:autologin]
        when Hash:  # Production
        cookies[:autologin][:value].first
        when Array:  # Not sure why this happens in development...
        cookies[:autologin].first
      else
        raise "Unknown cookie class: #{cookie.class}\n#{cookie.inspect}"
      end
      
      token = cookies[:token] && case cookies[:token]
        when String: # Development
        cookies[:token]
        when Hash:   # Production
        cookies[:token][:value].first
        when Array:  # Not sure why this happens in development...
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
        session[:user_id] = cookie_user.id
        return cookie_user
      end
    end
    
    # If not, is the user being authenticated by a token (created by signup/forgot password actions)?
    return false if not params['user']
    id = params['user']['id']
    key = params['key']
    if id and key
      @current_user = User.authenticate_by_token(id, key)
      session[:user_id] = @current_user ? @current_user.id : nil
      return true if not @current_user.nil?
    end
    
    # Everything failed
    return false
  end
  
  def user
    @current_user
  end
  
  def admin?
    user? && user.role == ADMIN_ROLE
  end
  
end
