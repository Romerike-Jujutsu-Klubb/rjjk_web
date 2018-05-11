# frozen_string_literal: true

class PublicRecordMailer < ApplicationMailer
  def new_record(record)
    @record = record
    @title = 'Ny informasjon registrert i Brønnøysund'
    # FIXME(uwe): Pick chairman from Election
    @chairman = User.find_by(first_name: 'Uwe', last_name: 'Kubosch').member
    @email_url = { controller: :public_records, action: :index }
    mail subject: @title, to: @chairman.email
  end
end
