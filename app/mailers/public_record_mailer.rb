# frozen_string_literal: true
class PublicRecordMailer < ActionMailer::Base
  include UserSystem
  include MailerHelper

  default from: noreply_address

  def new_record(record)
    @record = record
    @title = 'Ny informasjon registrert i Brønnøysund'
    @chairman = Member.find_by_first_name_and_last_name('Uwe', 'Kubosch')
    @email_url = with_login(@chairman.user, controller: :public_records, action: :index)
    mail subject: @title, to: @chairman.email
  end
end
