class SemesterMailer < ActionMailer::Base
  layout 'email'
  default from: Rails.env == 'production' ? 'noreply@jujutsu.no' : "#{Rails.env}@jujutsu.no",
          to: Rails.env == 'production' ? %w(curt.mekiassen@as.online.no uwe@kubosch.no) : 'uwe@kubosch.no'

  def missing_current_semester
    mail subject: '[RJJK] Planlegge semesteret'
  end

  def missing_next_semester
    mail subject: '[RJJK] Planlegge neste semester'
  end

  def missing_session_dates(group)
    @group = group
    mail subject: '[RJJK] Planlegge neste semester'
  end
end
