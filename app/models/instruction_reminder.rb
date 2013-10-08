#FIXME(uwe): Notify if CHIEF Instructor is missing.
class InstructionReminder
  def self.notify_missing_instructors
    semesters = Semester.where("start_on < (CURRENT_DATE + interval '3 months') AND end_on > CURRENT_DATE").order(:end_on).all
    missing_chief_instructions = semesters.map do |s|
      groups = Group.active(s.start_on).all
      group_schedules = groups.map(&:group_schedules).flatten.sort_by(&:weekday)
      group_schedules.select { |gs| gs.group_instructors.select do |gi|
        gi.active?(s.start_on) && gi.role = GroupInstructor::Role::CHIEF
      end.empty? }.map do |gs|
        GroupInstructor.new(:semester_id => s.id, :group_schedule => gs, :role => GroupInstructor::Role::CHIEF)
      end
    end.flatten
    missing_instructions = semesters.map do |s|
      groups = Group.active(s.start_on).all
      group_schedules = groups.map(&:group_schedules).flatten.sort_by(&:weekday)
      group_schedules.select { |gs| gs.group_instructors.select { |gi| gi.active?(s.start_on) }.empty? }.map do |gs|
        GroupInstructor.new(:semester_id => s.id, :group_schedule => gs)
      end
    end.flatten
    if missing_chief_instructions.any? || missing_instructions.any?
      InstructionMailer.missing_instructors(missing_chief_instructions, missing_instructions).deliver
    end
  rescue
    logger.error "Exception sending instruction message: #{$!}"
    logger.error $!.backtrace.join("\n")
  end
end
