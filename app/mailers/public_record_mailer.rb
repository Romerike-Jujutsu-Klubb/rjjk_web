class PublicRecordMailer < ActionMailer::Base
  include UserSystem
  include MailerHelper
  layout 'email'
  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no"

  def new_record(record)
    @record = record
    @title = 'Ny informasjon registrert i Brønnøysund'
    @chairman = Member.find_by_first_name_and_last_name('Uwe', 'Kubosch')
    @email_url = with_login(@chairman.user, :controller => :public_records, :action => :index)
    mail subject: rjjk_prefix(@title),
         to: Rails.env == 'production' ? @chairman.email : "\"#{@chairman.name}\" <uwe@kubosch.no>"
  end
end
