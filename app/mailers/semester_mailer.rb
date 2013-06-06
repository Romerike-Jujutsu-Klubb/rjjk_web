class SemesterMailer < ActionMailer::Base
  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no",
          to: Rails.env == 'production' ? %w(uwe@kubosch.no) : 'uwe@kubosch.no'

  def missing_current_semester
    mail subject: '[RJJK] Planlegge semesteret'
  end

  def missing_next_semester
    mail subject: '[RJJK] Planlegge neste semester'
  end
end
