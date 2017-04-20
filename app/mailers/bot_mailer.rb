# frozen_string_literal: true

class BotMailer < ApplicationMailer
  default from: "#{Rails.env}@jujutsu.no", to: 'uwe@kubosch.no'

  def reject(headers)
    @headers = headers
    mail subject: "[RJJK] #{Rails.env} Rejected BAIDU request"
  end
end
