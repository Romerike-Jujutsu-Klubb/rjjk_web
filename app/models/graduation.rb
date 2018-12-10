# frozen_string_literal: true

class Graduation < ApplicationRecord
  belongs_to :group
  has_many :censors, dependent: :destroy
  has_many :graduates, dependent: :destroy

  scope :for_edit, -> do
    includes(
        censors: { member: [{ graduates: { rank: :martial_art } }, :user] },
        graduates: {
          graduation: {
            group: {
              martial_art: { ranks: [{ group: %i[martial_art ranks] }, :martial_art] },
            },
          },
          member: [
            {
              attendances: {
                practice: :group_schedule,
              },
              graduates: [
                {
                  graduation: :group,
                },
                :rank,
              ],
            },
            :nkf_member,
          ],
          rank: [{ group: %i[group_schedules ranks] }, :martial_art],
        },
        group: { members: :nkf_member }
      )
  end
  scope :censors_confirmed,
      ->(date) { where(<<~SQL, date) }
        NOT EXISTS (
          SELECT confirmed_at
          FROM censors WHERE graduation_id = graduations.id
            AND confirmed_at <= ?
        )
      SQL
  scope :has_examiners,
      -> { where <<~SQL }
        EXISTS (
          SELECT id
          FROM censors WHERE graduation_id = graduations.id
            AND examiner = TRUE AND declined = FALSE
        )
      SQL
  scope :ready,
      ->(date) { has_examiners.where(<<~SQL, date: date) }
        NOT EXISTS (
          SELECT locked_at
          FROM censors WHERE graduation_id = graduations.id
            AND (locked_at IS NULL OR locked_at > :date)
            AND examiner = TRUE AND declined = FALSE
        )
      SQL
  scope :approved,
      ->(date) { where(<<~SQL, date, false) }
        NOT EXISTS (
          SELECT approved_grades_at
          FROM censors WHERE graduation_id = graduations.id
            AND (approved_grades_at IS NULL OR approved_grades_at > ?)
            AND (declined IS NULL OR declined = ?)
        )
      SQL
  scope :upcoming, -> { where 'held_on >= ?', Date.current }

  validates :group, :group_id, :held_on, presence: true
  validates :group_notification, inclusion: { in: [true, false], message: 'må velges' }
  validates :held_on, uniqueness: { scope: :group_id }

  validate do
    if was_locked?
      if attribute_changed?(:group_id)
        errors.add :group_id, 'kan ikke endres etter at graderingsoppsettet er låst'
      end
      if attribute_changed?(:held_on)
        errors.add :held_on, 'kan ikke endres etter at graderingsoppsettet er låst'
      end
    end
  end

  def start_at
    held_on&.at(group_schedule&.start_at || TimeOfDay.new(17, 45))
  end

  def end_at
    held_on.try(:at, group_schedule.try(:end_at) || TimeOfDay.new(20, 30))
  end

  def name
    "Gradering #{group.name}"
  end

  def attendees
    (graduates.select { |g| g.passed || g.passed.nil? } + censors).map(&:member).map(&:user)
  end

  def body
    admin?
  end

  def admin?(user: current_user, approval: nil)
    return true if approval || (user && censors.any? { |c| c.member == user.member })
    return true if user&.admin?
    return true if user && group&.current_semester&.chief_instructor == user.member
    return true if user && group&.current_semester&.group_instructors&.map(&:member)&.include?(user.member)

    false
  end

  def size
    graduates.select { |g| g.passed || g.passed.nil? }.size
  end

  def group_schedule
    return unless held_on

    group.group_schedules.find { |gs| gs.weekday == held_on.cwday }
  end

  def martial_art
    group.try(:martial_art) || MartialArt.find_by(name: 'Kei Wa Ryu')
  end

  def description
    name
  end

  def passed?
    (held_on&.< Date.current)
  end

  def locked?
    if held_on < GraduationReminder::CHIEF_INSTRUCTOR_LOCK_LIMIT.from_now &&
          censors.reject(&:declined?).select(&:locked_at).map(&:member)
                .include?(group.group_semesters.for_date(held_on).first&.chief_instructor)
      return true
    end

    non_declined_examiners = censors.select(&:examiner).reject(&:declined?)
    non_declined_examiners.any? && non_declined_examiners.all?(&:locked_at?)
  end

  def was_locked?
    if group_id_was
      chief_instructor = Group.find(group_id_was).group_semesters.for_date(held_on).first&.chief_instructor
      if held_on_was < GraduationReminder::CHIEF_INSTRUCTOR_LOCK_LIMIT.from_now &&
            censors.reject(&:declined?).select(&:locked_at).map(&:member).include?(chief_instructor)
        return true
      end
    end
    non_declined_examiners = censors.select(&:examiner).reject(&:declined?)
    non_declined_examiners.any? && non_declined_examiners.all?(&:locked_at?)
  end

  def approved?
    non_declined_censors = censors.reject(&:declined?)
    passed? && non_declined_censors.any? && non_declined_censors.all?(&:approved?)
  end

  def examiner_emails
    censors.select(&:examiner?).map(&:member).map(&:emails).flatten.uniq
  end
end
