# frozen_string_literal: true

module MailerHelper
  include ApplicationHelper

  def self.included(clas)
    clas.extend self
  end

  def rjjk_prefix(subject = nil)
    "[RJJK]#{"[#{Rails.env.upcase}]" unless Rails.env.production?} #{subject}".strip
  end

  def safe_email(member_or_user)
    if Rails.env.production?
      member_or_user.emails
    else
      %("#{member_or_user.name}" <uwe@kubosch.no>)
    end
  end

  def noreply_address
    "noreply@#{"#{Rails.env}." unless Rails.env.production?}jujutsu.no"
  end
end
