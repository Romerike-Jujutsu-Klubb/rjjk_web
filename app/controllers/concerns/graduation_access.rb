# frozen_string_literal: true
module GraduationAccess
  def admin_or_censor_required(graduation, approval = nil)
    return false unless authenticate_user
    return true if approval || admin?
    return true if graduation &&
          graduation.group.current_semester.group_instructors.map(&:member)
                .include?(current_user.member)
    access_denied('Du må være gruppeinstruktør, eksaminator, sensor eller administrator for å redigere graderinger.')
  end
end
