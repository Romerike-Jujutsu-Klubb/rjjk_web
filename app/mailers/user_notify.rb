class UserNotify < ActionMailer::Base
  default from: UserSystem::CONFIG[:email_from].to_s

  def signup(user, password, url=nil)
    setup_email(user)

    @subject += "Velkommen til #{UserSystem::CONFIG[:app_name]}!"

    @name = "#{user.first_name} #{user.last_name}"
    @login = user.login
    @password = password
    @url = url || UserSystem::CONFIG[:app_url].to_s
    @app_name = UserSystem::CONFIG[:app_name].to_s

    send_email
  end

  def created_from_member(user, password)
    setup_email(user)

    @subject += 'Velkommen til Romerike Jujutsu Klubb!'
    @user = user
    @password = password

    send_email
  end

  def forgot_password(user, url=nil)
    setup_email(user)

    @subject += 'Glemt passord'

    @name = "#{user.first_name} #{user.last_name}"
    @login = user.login
    @url = url || UserSystem::CONFIG[:app_url].to_s
    @app_name = UserSystem::CONFIG[:app_name].to_s

    send_email
  end

  def change_password(user, password, url=nil)
    setup_email(user)

    @subject += 'Passordbytte'

    @name = "#{user.first_name} #{user.last_name}"
    @login = user.login
    @password = password
    @url = url || UserSystem::CONFIG[:app_url].to_s
    @app_name = UserSystem::CONFIG[:app_name].to_s
    @email = user.email

    send_email
  end

  private

  def setup_email(user)
    @recipients = Rails.env != 'production' ? %Q{"#{user.emails.join(' ')}"<uwe@kubosch.no>} : user.emails
    @subject    = "[#{UserSystem::CONFIG[:app_name]}] "
    @sent_on    = Time.now
  end

  def send_email
    mail subject: @subject, to: @recipients
  end

end
