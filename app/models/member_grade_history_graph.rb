# frozen_string_literal: true

class MemberGradeHistoryGraph
  DEFAULT_INTERVAL = 2.months

  ACTIVE_CLAUSE = <<~SQL
    EXISTS (
      SELECT 1
      FROM attendances a
        INNER JOIN practices p ON p.id = a.practice_id
      WHERE user_id = users.id
        AND (p.year > :prev_date_year OR (p.year = :prev_date_year AND p.week >= :prev_date_week))
        AND (p.year < :date_year OR (p.year = :date_year AND p.week <= :date_week))
    )
    AND (
      :next_date > :current_date
      OR EXISTS (
        SELECT 1
        FROM attendances a
          INNER JOIN practices p ON p.id = a.practice_id
        WHERE user_id = users.id
          AND (p.year > :date_year OR (p.year = :date_year AND p.week >= :date_week))
          AND (p.year < :next_year OR (p.year = :next_year AND p.week <= :next_week))))
    AND (joined_on IS NULL OR joined_on <= :date)
    AND (left_on IS NULL OR left_on > :date)
  SQL

  ATTENDANCE_CLAUSE = '(SELECT COUNT(*)
                        FROM attendances a
                          INNER JOIN practices p ON p.id = a.practice_id
                        WHERE user_id = users.id
                          AND (p.year > ? OR (p.year = ? AND p.week >= ?))
                          AND (p.year < ? OR (p.year = ? AND p.week <= ?))
                        ) >= ?
                        AND (joined_on IS NULL OR joined_on <= ?)
                        AND (left_on IS NULL OR left_on > ?)'

  def initialize
    @practices = {}
    @active_members = {}
    @group = Group.includes(:group_schedules).find_by(name: 'Voksne')
  end

  def data_set(options)
    interval = options[:interval] || DEFAULT_INTERVAL
    step = (options[:step] || 3.months)
    percentage = options[:percentage]

    raise unless interval > 0 && step > 0

    ranks = CurriculumGroup.find_by(name: 'Voksne').ranks.reverse + [Rank::UNRANKED]
    # first_date = 5.years.ago.to_date
    # first_date = 10.years.ago.to_date
    first_date = Date.civil(2011, 1, 1)
    dates = Date.current.step(first_date, -step / 1.day).to_a.reverse
    ranks_data = ranks.map { |rank| totals(rank, dates, interval, percentage).map(&:size) }
    data = Hash[ranks.reverse.zip(ranks_data.reverse)].select { |_rank, values| values.any?(&:positive?) }
    [dates, data]
  end

  def ranks
    ranks = [Rank::UNRANKED] + MartialArt.kwr.first.curriculum_groups.find_by(name: 'Voksne').ranks
    ranks_data = ranks.map { |rank| totals(rank, [Date.current], DEFAULT_INTERVAL, nil)[0] }
    ranks.zip(ranks_data)
  end

  private

  def totals(rank, dates, interval, percentage)
    dates.each.map do |date|
      prev_date = date - interval
      next_date = date + interval
      @practices[date] ||= @group.trainings_in_period(prev_date..date)
      @active_members[date] ||= Member
          .includes(:user, graduates: [{ graduation: { group: :martial_art } }, :rank])
          .references(:users)
          .where(
              if percentage
                [ATTENDANCE_CLAUSE, prev_date.cwyear, prev_date.cwyear, prev_date.cweek,
                 date.cwyear, date.cwyear, date.cweek, (@practices[date] * percentage) / 100,
                 date, date]
              else
                [ACTIVE_CLAUSE, { current_date: Date.current,
                                  prev_date_year: prev_date.cwyear, prev_date_week: prev_date.cweek,
                                  date_year: date.cwyear, date_week: date.cweek,
                                  next_date: next_date, next_year: next_date.cwyear,
                                  next_week: next_date.cweek, date: date }]
              end
            )
          .to_a
      @active_members[date].select do |m|
        m.graduates.select { |g| g.passed? && g.graduation.held_on <= date }
            .max_by { |g| g.graduation.held_on }&.rank == rank
      end
    end
  end
end
