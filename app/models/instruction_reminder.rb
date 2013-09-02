class InstructionReminder
  def self.notify_missing_instructors
    semesters = Semester.where("start_on < (CURRENT_DATE + interval '3 months') AND end_on > CURRENT_DATE").order(:end_on).all
    missing_instructions = semesters.map do |s|
      groups = Group.active(s.start_on).all
      group_schedules = groups.map(&:group_schedules).flatten.sort_by(&:weekday)
      group_schedules.select { |gs| gs.group_instructors.select { |gi| gi.active?(s.start_on) }.empty? }.map do |gs|
        GroupInstructor.new(:semester_id => s.id, :group_schedule => gs)
      end
    end.flatten
    InstructionMailer.missing_instructors(missing_instructions).deliver if missing_instructions.any?
  rescue
    logger.error "Exception sending instruction message: #{$!}"
    logger.error $!.backtrace.join("\n")
  end
end
