# encoding: UTF-8
class UserController < ApplicationController
  before_filter :authenticate_user
  before_filter :admin_required, :except => [:welcome, :like, :login, :logout, :signup, :forgot_password, :change_password]

  skip_before_filter :authenticate_user, :only => [:login, :logout, :signup, :forgot_password]

  def list
    @users = User.all(:order => 'last_name, first_name')
  end

  def login
    return if generate_blank_form
    remember_me = params.delete(:remember_me)
    @user = User.new(params['user'])
    if (user = User.authenticate(params['user']['login'], params['user']['password']))
      self.current_user = user
      flash['notice'] = 'Velkommen!'
      if remember_me && remember_me == '1'
        cookies.permanent[:token] = user.generate_security_token(:login)
      end
      unless member?
        if (member = Member.find_by_email(user.email))
          user.update_attributes! :member_id => member.id
          flash['notice'] << "Du er nå registrert som medlem #{member.name}."
        end
      end
      back_or_redirect_to '/'
    else
      @login = params['user']['login']
      flash['message'] = 'Innlogging feilet.'
    end
  end

  def send_login_email
    user = User.find(params[:id])
    key = user.generate_security_token
    url = url_for(:action => 'welcome')
    url += "?user[id]=#{user.id}&key=#{key}"
    UserNotify.signup(user, user.password, url).deliver
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
          url = url_for(with_login(@user, :action => :welcome))
          UserNotify.signup(@user, params['user']['password'], url).deliver
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
    self.current_user = nil
    cookies[:token] = {:value => '', :expires => 0.days.from_now}
    flash['notice'] = 'Velkommen tilbake!'
    back_or_redirect_to '/'
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
      UserNotify.change_password(@user, params['user']['password']).deliver
    rescue Exception => ex
      report_exception ex
    end
    redirect_to :controller => :user, :action => :welcome
  end

  def forgot_password
    if authenticated_user? and not admin?
      flash['message'] = 'Du er nå logget på. Du kan nå endre passordet ditt.'
      redirect_to :action => 'change_password'
      return
    end

    params[:user][:email] ||= params[:user][:login] if params[:user]
    return if generate_blank_form

    email = params['user']['email']
    if email.blank? || email !~ /.+@.+\..+/
      flash.now['message'] = 'Skriv inn en gyldig e-postadresse.'
    elsif (users = User.find_by_contents(email)).empty?
      flash.now['message'] = "Vi kunne ikke finne noen bruker tilknyttet e-postadresse #{CGI.escapeHTML(email)}"
    else
      begin
        User.transaction do
          users.each do |user|
            key = user.generate_security_token
            url = url_for(:action => 'change_password')
            url += "?user[id]=#{user.id}&key=#{key}"
            UserNotify.forgot_password(user, url).deliver
          end
          flash['message'] = "En e-post med veiledning for å sette nytt passord er sendt til #{CGI.escapeHTML(email)}."
          unless authenticated_user?
            redirect_to :action => 'login'
            return
          end
          back_or_redirect_to '/'
        end
      rescue Exception => ex
        report_exception ex
        flash.now['message'] = "Beklager!  Link for innlogging kunne ikke sendes til #{CGI.escapeHTML(email)}"
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
          if current_user.admin?
            user_params = unclean_params
          else
            user_params = unclean_params.delete_if { |k, *| not User::CHANGEABLE_FIELDS.include?(k) }
          end
          @user.attributes = user_params
          if @user.save
            flash.now['notice'] = "User has been updated."
          end
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
    @user = current_user || User.find_by_id(session[:user_id])
    begin
      @user.update_attribute(:deleted, true)
      logout
    rescue Exception => ex
      flash.now['message'] = "Error: #{ex}."
      back_or_redirect_to '/'
    end
  end

  def welcome
  end

  def like
    UserImage.where(:user_id => current_user.id, :image_id => params[:id], :rel_type => 'LIKE').first_or_create!
    redirect_to :controller => :news, :action => :index
  end

  protected

  def protect?(action)
    !%w{login signup forgot_password}.include?(action)
  end

  # Generate a template user for certain actions on get
  def generate_blank_form
    case request.method
    when 'GET'
      @user = User.new params[:user]
      render
      true
    else
      false
    end
  end

  # Generate a template user for certain actions on get
  def generate_filled_in
    @user = (params[:id] && User.find_by_id(params[:id])) || current_user || User.find_by_id(session[:user_id])
    @members = Member.select('id, first_name, last_name').where(:email => @user.email).all
    case request.method
    when 'GET'
      render
      true
    else
      false
    end
  end

  def report_exception(ex)
    logger.warn ex
    logger.warn ex.backtrace.join("\n")
  end

end
