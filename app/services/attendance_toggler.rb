# frozen_string_literal: true

module AttendanceToggler
  def self.toggle(attendance)
    if attendance.status == Attendance::Status::WILL_ATTEND
      Attendance::Status::ATTENDED if attendance.practice.imminent?
    elsif attendance.status == Attendance::Status::INSTRUCTOR ||
          attendance.status == Attendance::Status::ASSISTANT
      if attendance.practice.imminent?
        Attendance::Status::ABSENT
      else
        Attendance::Status::WILL_ATTEND
      end
    elsif attendance.status == Attendance::Status::ATTENDED
      Attendance::Status::ABSENT if attendance.practice.imminent?
    elsif attendance.practice.imminent?
      Attendance::Status::ATTENDED
    elsif attendance.practice.instructor?(attendance.user.member)
      Attendance::Status::INSTRUCTOR
    else
      Attendance::Status::WILL_ATTEND
    end
  end
end
