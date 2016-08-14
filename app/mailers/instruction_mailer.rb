class InstructionMailer < ActionMailer::Base
  include MailerHelper
  layout 'email'
  default from: noreply_address,
          to: Rails.env == 'production' ? %w(uwe@kubosch.no) : 'uwe@kubosch.no'

  def missing_instructors(missing_chief_instructions, missing_instructions)
    @chief_semesters = missing_chief_instructions
    @semesters = missing_instructions.group_by(&:group_semester)
    @title = 'Treningsgrupper som mangler instruktør'
    mail subject: rjjk_prefix(@title)
  end
end
