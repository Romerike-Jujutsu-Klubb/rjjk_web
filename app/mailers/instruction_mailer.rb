# encoding: utf-8
class InstructionMailer < ActionMailer::Base
  layout 'email'
  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no",
          to: Rails.env == 'production' ? %w(uwe@kubosch.no) : 'uwe@kubosch.no'

  def missing_instructors(missing_chief_instructions, missing_instructions)
    @missing_chief_instructions = missing_chief_instructions
    @semesters = missing_instructions.group_by(&:semester)
    @chief_semesters = missing_chief_instructions.group_by(&:semester)
    mail subject: 'Treningsgrupper som mangler instruktør'
  end

end
