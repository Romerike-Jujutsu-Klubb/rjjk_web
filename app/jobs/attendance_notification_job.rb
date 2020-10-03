# frozen_string_literal: true

class AttendanceNotificationJob < ApplicationJob
  queue_as :default

  # FIXME(uwe): Only send about practice later today after 0800.
  # FIXME(uwe): Do this in a background job to avoid slow response
  def perform(practice, user, new_status)
    attendances = practice.attendances
    attendees = attendances.count { |a| Attendance::PRESENCE_STATES.include?(a.status) }
    absentees = attendances.count { |a| Attendance::ABSENT_STATES.include?(a.status) }
    group_name = practice.group_schedule.group.name
    body = +"#{attendees} er påmeldt."
    body << "\n#{absentees} er avmeldt." if absentees > 0
    AttendanceWebpush
        .push_all(
            "#{user.name}: #{new_status.inspect} #{group_name} #{practice.date}",
            body,
            except: user.id,
            tag: "attendance_#{user.id}_#{practice.id}",
            data: {
              user_id: user.id,
              practice_id: practice.id,
            }
          )
  end
end
