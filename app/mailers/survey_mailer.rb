class SurveyMailer < ActionMailer::Base
  include UserSystem
  include MailerHelper
  default bcc: 'uwe@kubosch.no',
      from: Rails.env == 'production' ? 'medlem@jujutsu.no' : "#{Rails.env}@jujutsu.no"
  layout 'email'

  def survey(survey_request)
    @survey_request = survey_request
    @user_email = survey_request.member.email
    @title = survey_request.survey.title
    @timestamp = Time.now
    @email_url = with_login(survey_request.member.user,
        controller: :survey_requests, action: :answer_form, id: survey_request.id)
    mail to: safe_email(survey_request.member), subject: rjjk_prefix(@title)
  end

  def reminder(survey_request)
    @survey_request = survey_request
    @user_email = survey_request.member.email
    @title = survey_request.survey.title
    @timestamp = Time.now
    @email_url = with_login(survey_request.member.user,
        controller: :survey_requests, action: :answer_form, id: survey_request.id)
    mail to: safe_email(survey_request.member), subject: rjjk_prefix(@title)
  end
end
