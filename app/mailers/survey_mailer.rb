# frozen_string_literal: true

class SurveyMailer < ApplicationMailer
  default bcc: 'uwe@kubosch.no',
          from: "medlem@#{"#{Rails.env}." unless Rails.env.production?}jujutsu.no"

  def survey(survey_request)
    @survey_request = survey_request
    @user_email = survey_request.member.email
    @title = survey_request.survey.title
    @timestamp = Time.current
    @email_url = { controller: :survey_requests, action: :answer_form, id: survey_request.id }
    mail to: survey_request.member.email, subject: @title
  end

  def reminder(survey_request)
    @survey_request = survey_request
    @user_email = survey_request.member.email
    @title = survey_request.survey.title
    @timestamp = Time.current
    @email_url = { controller: :survey_requests, action: :answer_form, id: survey_request.id }
    mail to: survey_request.member.email, subject: @title
  end
end
