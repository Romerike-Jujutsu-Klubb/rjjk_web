# frozen_string_literal: true

class InstructionMailer < ApplicationMailer
  default to: Rails.env.production? ? %w[uwe@kubosch.no] : 'uwe@kubosch.no'

  def missing_instructors(missing_chief_instructions, missing_instructions)
    @chief_semesters = missing_chief_instructions
    @semesters = missing_instructions.group_by { |i| i.group_semester.semester }
    @title = 'Treningsgrupper som mangler instruktør'
    mail subject: @title
  end
end
