# frozen_string_literal: true

class SmsController < ApplicationController
  before_action :admin_required

  def index
    @recipients = params.dig(:user, :id).to_a.reject(&:blank?).map(&:to_i)
    @users = User.order(:first_name, :last_name).to_a
  end

  def create
    recipients = params[:user][:id].to_a.reject(&:blank?).map(&:to_i)
    text = params[:user][:text]
    if recipients.blank? || text.blank?
      flash.notice = 'Velg mottakere og skriv inn en melding.'
      redirect_to sms_path
      return
    end
    users = User.find(recipients)
    begin
      User.transaction do
        users.each do |user|
          raise 'Huh?' unless user.contact_phone

          if Datek::Cpas.base_url
            Datek::Cpas.send_sms to: user.contact_phone, text: text
          else
            flash.notice = 'SMS-utsending er ikke aktiv.'
          end
        end
      end
      flash.notice = "SMS er sendt til #{users.size} mottakere."
      back_or_redirect_to sms_path
    rescue => e
      report_exception e
      flash.now.alert = "Beklager!  SMS kunne ikke sendes til #{recipients.size} mottakere."
    end
  end
end
