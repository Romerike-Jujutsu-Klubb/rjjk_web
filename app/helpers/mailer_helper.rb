# frozen_string_literal: true

module MailerHelper
  include ApplicationHelper

  def self.included(clas)
    clas.extend self
  end

  def rjjk_prefix(subject = nil)
    "[RJJK]#{"[#{Rails.env.upcase}]" unless Rails.env.production?} #{subject}".strip
  end

  def safe_email(recipient)
    emails = recipient.respond_to?(:emails) ? recipient.emails : recipient
    Rails.env.production? ? emails : %("#{emails[0]}" <uwe@kubosch.no>)
  end

  def noreply_address
    "noreply@#{"#{Rails.env}." unless Rails.env.production?}jujutsu.no"
  end
end
