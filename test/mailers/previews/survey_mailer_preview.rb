# Preview all emails at http://localhost:3000/rails/mailers/survey_mailer
class SurveyMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/survey_mailer/survey
  def survey
    SurveyMailer.survey
  end

  # Preview this email at http://localhost:3000/rails/mailers/survey_mailer/reminder
  def reminder
    SurveyMailer.reminder
  end

end
