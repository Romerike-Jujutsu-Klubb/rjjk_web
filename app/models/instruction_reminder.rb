class InstructionReminder
  def self.notify_missing_instructors
    semesters = Semester.where("start_on < (CURRENT_DATE + interval '3 months') AND end_on > CURRENT_DATE").order(:end_on).to_a
    missing_chief_instructions =
        semesters.map(&:group_semesters).flatten.reject(&:chief_instructor_id)
    missing_instructions = semesters.map(&:group_semesters).flatten.map do |gs|
      group_schedules = gs.group.group_schedules.sort_by(&:weekday)
      group_schedules.select { |gsc| gsc.group_instructors.select { |gi| gi.active?(gs.semester.start_on) }.empty? }.map do |gsc|
        GroupInstructor.new(:group_semester_id => gs.id, :group_schedule => gsc)
      end
    end.flatten
    if missing_chief_instructions.any? || missing_instructions.any?
      InstructionMailer.missing_instructors(missing_chief_instructions, missing_instructions).deliver
    end
  rescue
    raise if Rails.env.test?
    logger.error "Exception sending instruction message: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end
end
