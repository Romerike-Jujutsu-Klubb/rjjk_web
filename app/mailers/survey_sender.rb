# * fetch surveys by survey.priority/position
# * send to longest joined member first
# * Send one per day, or so.
# * Resend after a week or so, not before
# * Store sending of survey
# * Sore answers
# * Send no more than one survey per week.
# * Check survey conditions: active members / left members / passive members / panda / tiger / voksne

# Survey active/passive/left group title position/priority expires_at header footer
# SurveyQuestion survey_id:integer title:string choices:string free_text:boolean
# SurveyRequest survey_id:integer member_id:integer completed_at:datetime
# SurveyAnswer survey_request_id:integer survey_question_id:integer answer:string
# SurveyAnswerTranslation answer:string normalized_answer:string
class SurveySender
  def self.send_surveys
    begin
      logger.info 'Checking surveys!'
      request = nil
      Survey.order(:position).each do |survey|
        unrequested_member = survey.ready_members.select(&:active?).first
        if unrequested_member
          request = survey.survey_requests.first_or_create!(member_id: unrequested_member.id)
        else
          request = survey.survey_requests.pending.
              select { |sr| sr.reminded_at.nil? || sr.reminded_at < 1.week.ago }.
              first
        end
        break if request
      end
      return unless request

      if request.sent_at.nil?
        SurveyMailer.survey(request).deliver
        request.update sent_at: Time.now
      else
        SurveyMailer.reminder(request).deliver
        request.update reminded_at: Time.now
      end
    rescue
      logger.error 'Execption sending survey request.'
      logger.error $!.message
      logger.error $!.backtrace.join("\n")
      ExceptionNotifier.notify_exception($!)
    end

  end
end
