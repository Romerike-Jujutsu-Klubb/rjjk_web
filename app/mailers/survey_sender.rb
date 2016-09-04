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
            survey.survey_requests
                .where(member_id: unrequested_member.id).first_or_create!
          else
            survey.survey_requests.pending
                .select { |sr| sr.reminded_at.nil? || sr.reminded_at < 1.week.ago }
                .first
          end
      break if request
    end
    return unless request

    if request.sent_at.nil?
      SurveyMailer.survey(request).store(request.member.user_id, tag: :suvey_request)
      request.update! sent_at: Time.now
    else
      SurveyMailer.reminder(request).store(request.member.user_id, tag: :survey_reminder)
      request.update! reminded_at: Time.now
    end
  end
end
