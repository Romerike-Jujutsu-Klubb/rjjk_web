class UserController < ApplicationController
  before_filter :authenticate_user
  before_filter :admin_required, :except => [:welcome, :login, :logout, :signup, :forgot_password, :change_password]

  skip_before_filter :authenticate_user, :only => [ :login, :signup, :forgot_password ]

  def list
    @users = User.find(:all, :order => 'last_name, first_name')
  end
  
  def login
    return if generate_blank_form
    remember_me = params.delete(:remember_me)
    @user = User.new(params['user'])
    user = User.authenticate(params['user']['login'], params['user']['password'])
    if user
      @current_user = user
      session[:user_id] = user.id
      flash['notice'] = 'Login succeeded'
      if remember_me && remember_me == '1'
        user.generate_security_token
        cookies[:autologin] = {:value => user.id.to_s, :expires =>90.days.from_now}
        cookies[:token]     = {:value => user.security_token, :expires =>90.days.from_now}
      end
      redirect_back_or_default :action => 'welcome'
    else
      @login = params['user']['login']
      flash['message'] = 'Login failed'
    end
  end

  def signup
    return if generate_blank_form
    @user = User.new(
      :login => params['user'][:login],
      :password => params['user'][:password],
      :password_confirmation => params['user'][:password_confirmation],
      :email => params['user'][:email],
      :first_name => params['user'][:first_name],
      :last_name => params['user'][:last_name]
    )
    begin
      User.transaction do
        @user.password_needs_confirmation = true
        if @user.save
          key = @user.generate_security_token
          url = url_for(:action => 'welcome')
          url += "?user[id]=#{@user.id}&key=#{key}"
          UserNotify.deliver_signup(@user, params['user']['password'], url)
          flash['notice'] = 'Signup successful! Please check your registered email account to verify your account registration and continue with the login.'
          redirect_to :action => 'login'
        end
      end
    rescue Exception => ex
      report_exception ex
      flash['message'] = 'Error creating account: confirmation email not sent'
    end
  end  
  
  def logout
    session[:user_id] = nil
    @current_user = nil
    redirect_to :action => 'login'
  end

  def change_password
    return if generate_filled_in
    params['user'].delete('form')
    begin
      @user.change_password(params['user']['password'], params['user']['password_confirmation'])
      @user.save!
    rescue Exception => ex
      report_exception ex
      flash.now['message'] = 'Your password could not be changed at this time. Please retry.'
      render and return
    end
    begin
      UserNotify.deliver_change_password(@user, params['user']['password'])
    rescue Exception => ex
      report_exception ex
    end

  end

  def forgot_password
    if authenticated_user?
      flash['message'] = 'You are currently logged in. You may change your password now.'
      redirect_to :action => 'change_password'
      return
    end

    return if generate_blank_form

    if params['user']['email'].empty?
      flash.now['message'] = 'Please enter a valid email address.'
    elsif (user = User.find_by_email(params['user']['email'])).nil?
      flash.now['message'] = "We could not find a user with the email address #{CGI.escapeHTML(params['user']['email'])}"
    else
      begin
        User.transaction do
          key = user.generate_security_token
          url = url_for(:action => 'change_password')
          url += "?user[id]=#{user.id}&key=#{key}"
          UserNotify.deliver_forgot_password(user, url)
          flash['notice'] = "Instructions on resetting your password have been emailed to #{CGI.escapeHTML(params['user']['email'])}."
          unless authenticated_user?
            redirect_to :action => 'login'
            return
          end
          redirect_back_or_default :action => 'welcome'
        end
      rescue Exception => ex
        report_exception ex
        flash.now['message'] = "Your password could not be emailed to #{CGI.escapeHTML(params['user']['email'])}"
      end
    end
  end

  def edit
    return if generate_filled_in
    if params['user']['form']
      form = params['user'].delete('form')
      begin
        case form
        when "edit"
          unclean_params = params['user']
          user_params = unclean_params.delete_if { |k,v| not User::CHANGEABLE_FIELDS.include?(k) }
          @user.attributes = user_params
          @user.save
          flash.now['notice'] = "User has been updated."
        when "change_password"
          change_password
        when "delete"
          delete
        else
          raise "unknown edit action"
        end
      rescue Exception => ex
        logger.warn ex
        logger.warn ex.backtrace
      end
    end
  end

  def delete
    @user = @current_user || User.find_by_id( session[:user_id] )
    begin
      @user.update_attribute( :deleted, true )
      logout
    rescue Exception => ex
      flash.now['message'] = "Error: #{@ex}."
      redirect_back_or_default :action => 'welcome'
    end
  end

  def welcome
  end

  protected

  def protect?(action)
    if ['login', 'signup', 'forgot_password'].include?(action)
      return false
    else
      return true
    end
  end

  # Generate a template user for certain actions on get
  def generate_blank_form
    case request.method
    when :get
      @user = User.new
      render
      return true
    end
    return false
  end

  # Generate a template user for certain actions on get
  def generate_filled_in
    @user = (params[:id] && User.find_by_id(params[:id])) || @current_user || User.find_by_id(session[:user_id])
    case request.method
    when :get
      render
      return true
    end
    return false
  end

  def report_exception( ex )
    logger.warn ex
    logger.warn ex.backtrace.join("\n")
  end

end
