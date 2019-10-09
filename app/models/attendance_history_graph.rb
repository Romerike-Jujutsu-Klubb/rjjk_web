# frozen_string_literal: true

class AttendanceHistoryGraph
  def self.history_graph_data
    first_date = Date.civil(2010, 8, 1)
    weeks = []
    Date.current.step(first_date, -28) { |date| weeks << [date.cwyear, date.cweek] }
    weeks.reverse!
    totals = Array.new(weeks.size - 1, nil)
    totals_sessions = Array.new(weeks.size - 1, 0)
    group_data = Group.order('martial_art_id, from_age DESC, to_age').to_a.map do |group|
      attendances = weeks.each_cons(2).map do |w1, w2|
        Attendance.by_group_id(group.id).includes(:practice)
            .where('(practices.year > ? OR (practices.year = ? AND practices.week > ?))
AND (practices.year < ? OR (practices.year = ? AND practices.week <= ?))',
                w1[0], w1[0], w1[1], w2[0], w2[0], w2[1]).to_a +
            TrialAttendance.by_group_id(group.id)
            .where('year > ? OR (year = ? AND week > ?)', w1[0], w1[0], w1[1])
            .where('year < ? OR (year = ? AND week <= ?)', w2[0], w2[0], w2[1]).to_a
      end
      sessions = attendances.map { |ats| ats.map(&:practice_id).uniq.size }
      values = attendances.map
          .with_index { |a, i| sessions[i].positive? ? a.size / sessions[i] : nil }
      next unless values.any? { |v| v }

      sessions.each.with_index do |session, i|
        totals[i] = totals[i].to_i + values[i] if values[i]
        totals_sessions[i] += session
      end
      [group.name, values, group.color]
    end

    labels = make_week_labels(totals, weeks)

    [group_data, weeks, labels]
  end

  def self.make_week_labels(totals, weeks)
    labels = {}
    current_year = nil
    current_month = nil
    weeks.each_with_index do |week, i|
      year = week[0]
      month = Date.commercial(week[0], week[1], 2).mon
      next unless totals[i] && (current_month.nil? ||
          ((month - current_month > 1) && [1, 8].include?(month)) ||
          year != current_year)

      labels[i] = year != current_year ? "#{month}\n    #{year}" : month.to_s
      current_year = year
      current_month = month
    end
    labels
  end

  def self.month_per_year_chart_data(month)
    result = Attendance.connection.execute <<~SQL
      SELECT g.name, p.year as year, count(*) as count
      FROM attendances a
        LEFT JOIN practices p ON p.id = a.practice_id
        LEFT JOIN group_schedules gs ON gs.id = p.group_schedule_id
        LEFT JOIN groups g ON g.id = gs.group_id
      WHERE a.status NOT IN (#{Attendance::ABSENT_STATES.map { |s| "'#{s}'" }.join(',')})
        AND DATE_PART('month', date_trunc('week', (p.year || '-1-4')::date)::date + 7 * (p.week - 1) + gs.weekday) = #{month}
      GROUP BY g.name, p.year
      ORDER BY g.name, p.year
    SQL

    years = result.map { |r| r['year'] }.sort.uniq
    data = result.group_by { |r| r['name'] }.map do |group, values|
      [group, values.map { |v| [v['year'], v['count']] }, Group.find_by(name: group).color]
    end
    [data, years]
  end

  def self.month_chart_data(year, month)
    first_date = Date.civil(year, month, 1)
    last_date = [Date.civil(year, month, -1), Date.current].min
    attendances = Attendance.includes(:practice).references(:practices)
        .from_date(first_date).to_date(last_date)
        .where('attendances.status NOT IN (?)', Attendance::ABSENT_STATES)
        .to_a
    group_schedules = attendances.map(&:group_schedule).uniq
    groups = group_schedules.map(&:group).uniq.sort_by(&:from_age)
    dates = attendances.map(&:date).sort.uniq
    data = groups.map do |group|
      values = dates.select { |d| group.group_schedules.map(&:weekday).include? d.cwday }.map do |d|
        [d.day, attendances.count { |a| a.group_schedule.group == group && a.date == d }]
      end
      values.map! { |k, v| [k, v.positive? ? v : nil] }
      [group.name, values, group.color] if values.any? { |v| v }
    end
    data.compact!
    [data, dates]
  end
end
