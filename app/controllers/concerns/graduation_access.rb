# frozen_string_literal: true

module GraduationAccess
  def admin_or_censor_required(graduation, approval = nil)
    return access_denied('Du må logge inn for å redigere graderinger.') unless authenticate_user
    return true if admin?
    return true if graduation_admin?(graduation, approval)
    access_denied('Du må være hovedinstruktør, gruppeinstruktør, eksaminator, sensor eller ' \
        'administrator for å redigere graderinger.')
  end

  def graduation_admin?(graduation, approval)
    return true if approval || graduation.censors.any? { |c| c.member == current_user.member }
    return true if graduation&.group&.current_semester&.chief_instructor&.member == current_user.member
    return true if graduation&.group&.current_semester&.group_instructors&.map(&:member)
          &.include?(current_user.member)
    false
  end

  def admin_or_graduate_required(graduate)
    return false unless authenticate_user
    return true if admin?
    return true if graduate&.member == current_user.member
    access_denied('Du kan bare bekrefte din egen graderingspåmlding.')
  end
end
