# frozen_string_literal: true

class LoginController < ApplicationController
  EMAIL_COOKIE_NAME =
      :"#{'rjjk_' if Rails.env.development?}email#{"_#{Rails.env}" unless Rails.env.production?}"

  before_action :authenticate_user, except: %i[forgot_password login_link_form login_link_message_sent
                                               login_with_password logout send_login_link signup]

  def login_with_password
    return if generate_blank_form

    remember_me = params.delete(:remember_me)
    if (user = User.authenticate(params['user']['login'], params['user']['password']))
      self.session_user = user
      flash['notice'] = 'Velkommen!'
      store_cookie(current_user) if remember_me && remember_me == '1'
      back_or_redirect_to '/'
    else
      # @login = params['user']['login']
      @user = User.new(params['user'])
      flash.now.notice = 'Innlogging feilet.'
    end
  end

  def login_link_form
    @email = cookies.encrypted[EMAIL_COOKIE_NAME]
  end

  def send_login_link
    email = params[:user][:email]
    escaped_email = CGI.escapeHTML(email)
    if email.blank? || email !~ /.+@.+\..+/
      flash.notice = 'Skriv inn en gyldig e-postadresse.'
      redirect_to :login
    elsif (users_by_email = User.search(email).uniq).empty?
      flash.notice = "Vi kunne ikke finne noen bruker tilknyttet e-postadresse #{escaped_email}"
      redirect_to :login
    else
      cookies.permanent.encrypted[EMAIL_COOKIE_NAME] = { value: escaped_email }.merge(COOKIE_SCOPE)
      begin
        users = users_by_email - [current_user]
        if users.any?
          User.transaction do
            users.each { |user| UserMailer.login_link(user).store(user, tag: :login_link) }
          end
          if current_user
            flash.notice = "En e-post med innloggingslenke er sendt til #{escaped_email}."
            back_or_redirect_to login_link_message_sent_path
          else
            flash[:message_email] = escaped_email
            redirect_to login_link_message_sent_path email: email
          end
        else
          flash.notice = 'Du er allerede logget på.'
          redirect_to :login
        end
      rescue => e
        report_exception e
        flash.now[:notice] = "Beklager!  Link for innlogging kunne ikke sendes til #{escaped_email}"
      end
    end
  end

  def login_link_message_sent
    back_or_redirect_to root_path if current_user && !params[:email]
  end

  def signup
    return if generate_blank_form

    @user = User.new(
        login: params['user'][:login],
        password: params['user'][:password],
        password_confirmation: params['user'][:password_confirmation],
        email: params['user'][:email],
        first_name: params['user'][:first_name],
        last_name: params['user'][:last_name]
      )
    begin
      User.transaction do
        @user.password_needs_confirmation = true
        if @user.save
          url = url_for(with_login(@user, action: :welcome))
          UserMailer.signup(@user, params['user']['password'], url)
              .store(@user.id, tag: :signup)
          flash['notice'] = 'Signup successful! Please check your registered "\
"email account to verify your account registration and continue with the login.'
          redirect_to login_path
        end
      end
    rescue => e
      report_exception e
      flash.notice = 'Error creating account: confirmation email not sent'
    end
  end

  def logout
    self.session_user = nil
    clear_cookie
    reset_session
    if params[:reply]
      render plain: params[:reply]
      return
    end
    flash.notice = 'Velkommen tilbake!'
    back_or_redirect_to '/'
  end

  def change_password
    return if generate_filled_in

    params['user'].delete('form')
    begin
      @user.change_password(params['user']['password'], params['user']['password_confirmation'])
      @user.save!
    rescue => e
      report_exception e
      flash.now.notice = 'Your password could not be changed at this time. Please retry.'
      return
    end
    begin
      UserMailer.change_password(@user, params['user']['password'])
          .store(@user.id, tag: :change_password)
    rescue => e
      report_exception e
    end
    redirect_to controller: :login, action: :welcome
  end

  def forgot_password
    if authenticated_user? && !admin?
      flash.notice = 'Du er nå logget på. Du kan nå endre passordet ditt.'
      redirect_to action: 'change_password'
      return
    end

    params[:user][:email] ||= params[:user][:login] if params[:user]
    return if generate_blank_form

    email = params[:user][:email]
    escaped_email = CGI.escapeHTML(email)
    if email.blank? || email !~ /.+@.+\..+/
      flash.now.notice = 'Skriv inn en gyldig e-postadresse.'
    elsif (users_by_email = User.search(email).uniq).empty?
      flash.now.notice = "Vi kunne ikke finne noen bruker tilknyttet e-postadresse #{escaped_email}"
    else
      begin
        users = users_by_email - [current_user]
        if users.any?
          User.transaction do
            users.each do |user|
              url = url_for(action: :change_password)
              UserMailer.forgot_password(user, url).store(user, tag: :forgot_password)
            end
            flash.notice =
                "En e-post med veiledning for å sette nytt passord er sendt til #{escaped_email}."
            unless authenticated_user?
              redirect_to login_path
              return
            end
          end
          back_or_redirect_to '/'
        else
          flash.notice = 'Du er nå logget på. Du kan nå endre passordet ditt.'
          redirect_to action: 'change_password'
          return
        end
      rescue => e
        report_exception e
        flash.now[:notice] = "Beklager!  Link for innlogging kunne ikke sendes til #{escaped_email}"
      end
    end
  end

  def update
    @user = User.find_by(id: params[:id]) || current_user
    if params['user']['form']
      form = params['user'].delete('form')
      begin
        case form
        when 'edit'
          unclean_params = params['user']
          user_params =
              if current_user.admin?
                unclean_params
              else
                unclean_params.delete_if { |k, *| !User::CHANGEABLE_FIELDS.include?(k) }
              end
          @user.attributes = user_params
          flash.now['notice'] = 'User has been updated.' if @user.save
        when 'change_password'
          change_password
        when 'delete'
          delete
          return
        else
          raise 'unknown edit action'
        end
      rescue => e
        logger.warn e
        logger.warn e.backtrace
      end
    end
    redirect_to action: :edit
  end

  def welcome; end

  def like
    UserImage.where(user_id: current_user.id, image_id: params[:id], rel_type: 'LIKE')
        .first_or_create!
    redirect_to news_items_path
  end

  protected

  def protect?(action)
    !%w[login signup forgot_password].include?(action)
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
    @user = (params[:id] && User.find_by(id: params[:id])) || current_user ||
        User.find_by(id: session[:user_id])
    case request.method
    when 'GET'
      render
      true
    else
      false
    end
  end
end
