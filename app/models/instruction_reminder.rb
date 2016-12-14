# frozen_string_literal: true
class InstructionReminder
  def self.notify_missing_instructors
    semesters = Semester
        .where("start_on < (:current_date::date + interval '3 months')", current_date: Date.current)
        .where('end_on > :current_date::date', current_date: Date.current)
        .order(:end_on).to_a
    missing_chief_instructions =
        semesters.map(&:group_semesters).flatten.reject(&:chief_instructor_id)
    missing_instructions = semesters.map(&:group_semesters).flatten.map do |gs|
      group_schedules = gs.group.group_schedules.sort_by(&:weekday)
      group_schedules
          .select do |gsc|
        gsc.group_instructors.select { |gi| gi.active?(gs.semester.start_on) }.empty?
      end
          .map do |gsc|
        GroupInstructor.new(group_semester_id: gs.id, group_schedule: gsc)
      end
    end.flatten
    return if missing_chief_instructions.empty? && missing_instructions.empty?
    InstructionMailer
        .missing_instructors(missing_chief_instructions, missing_instructions)
        .store(Role[:Hovedinstruktør], tag: :missing_instructors)
  end
end
