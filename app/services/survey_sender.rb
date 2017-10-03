# frozen_string_literal: true

# * fetch surveys by survey.priority/position
# * send to longest joined member first
# * Send one per day, or so.
# * Resend after a week or so, not before
# * Store sending of survey
# * Store answers
# * Send no more than one survey per week.
# Check survey conditions: active members / left members / passive members / panda / tiger / voksne

# Survey active/passive/left group title position/priority expires_at header footer
# SurveyQuestion survey_id:integer title:string choices:string free_text:boolean
# SurveyRequest survey_id:integer member_id:integer completed_at:datetime
# SurveyAnswer survey_request_id:integer survey_question_id:integer answer:string
# SurveyAnswerTranslation answer:string normalized_answer:string
class SurveySender
  def self.send_surveys
    logger.info 'Checking surveys!'
    request = nil
    Survey.order(:position).each do |survey|
      unrequested_member = survey.ready_members.select(&:active?).first
      request =
          if unrequested_member
            survey.survey_requests.where(member_id: unrequested_member.id).first_or_create!
          else
            survey.survey_requests.pending
                .select { |sr| sr.reminded_at.nil? || sr.reminded_at < 1.week.ago }
                .sort_by { |sr| [sr.reminded_at.nil? ? 0 : 1, sr.reminded_at || sr.sent_at] }
                .first
          end
      break if request
    end
    return unless request

    if request.sent_at.nil?
      SurveyMailer.survey(request).store(request.member.user_id, tag: :suvey_request)
      request.update! sent_at: Time.current
    else
      SurveyMailer.reminder(request).store(request.member.user_id, tag: :survey_reminder)
      request.update! reminded_at: Time.current
    end
  end

  def self.notify_new_ansers
    new_answers = SurveyAnswer.where('created_at >= ?', 1.week.ago).to_a
    return if new_answers.empty?
    last_year = SurveyAnswer.where('created_at >= ?', 1.year.ago).to_a
    total = SurveyAnswer.all.to_a
    [Role[:Hovedinstruktør], Role[:Medlemsansvarlig]].compact.map(&:user).each do |user|
      SurveyMailer.new_answers(user, new_answers, last_year, total).store(user)
    end
  end
end
