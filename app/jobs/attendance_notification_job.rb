# frozen_string_literal: true

class AttendanceNotificationJob < ApplicationJob
  queue_as :default

  # FIXME(uwe): Only send about practice later today after 0800.
  # FIXME(uwe): Do this in a background job to avoid slow response
  def perform(practice, member, new_status)
    attendances = practice.attendances
    attendees = attendances.select { |a| Attendance::PRESENCE_STATES.include?(a.status) }.size
    absentees = attendances.select { |a| Attendance::ABSENT_STATES.include?(a.status) }.size
    group_name = practice.group_schedule.group.name
    body = +"#{attendees} er påmeldt."
    body << "\n#{absentees} er avmeldt." if absentees > 0
    AttendanceWebpush
        .push_all("#{member.name}: #{new_status.inspect} #{group_name} #{practice.date}",
            body,
            except: member.id,
        tag: "attendance_#{member.id}_#{practice.id}")
  end
end
