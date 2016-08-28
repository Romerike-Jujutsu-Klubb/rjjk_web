# frozen_string_literal: true
class AttendanceHistoryGraph
  def history_graph(size = 480)
    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = 'Oppmøte'
    g.title_font_size = 18
    g.legend_font_size = 14
    g.marker_font_size = 14
    g.hide_dots = true
    g.colors = %w(blue orange black green)
    g.x_axis_label = ''
    g.y_axis_increment = 5
    first_date = Date.civil(2010, 8, 1)
    weeks = []
    Date.today.step(first_date, -28) { |date| weeks << [date.cwyear, date.cweek] }
    weeks.reverse!
    totals = Array.new(weeks.size - 1, nil)
    totals_sessions = Array.new(weeks.size - 1, 0)
    Group.order('martial_art_id, from_age DESC, to_age').to_a.each do |group|
      attendances = weeks.each_cons(2).map do |w1, w2|
        Attendance.by_group_id(group.id).includes(:practice)
            .where('(practices.year > ? OR (practices.year = ? AND practices.week > ?))
AND (practices.year < ? OR (practices.year = ? AND practices.week <= ?))',
                w1[0], w1[0], w1[1], w2[0], w2[0], w2[1]).to_a +
            TrialAttendance.by_group_id(group.id).where('(year > ? OR (year = ? AND week > ?)) AND (year < ? OR (year = ? AND week <= ?))',
                w1[0], w1[0], w1[1], w2[0], w2[0], w2[1]).to_a
      end
      sessions = attendances.map { |ats| ats.map(&:practice_id).uniq.size }
      values = attendances.each_with_index.map { |a, i| sessions[i].positive? ? a.size / sessions[i] : nil }
      next unless values.any? { |v| v }
      g.data(group.name, values, group.color)
      sessions.each_with_index do |session, i|
        totals[i] = totals[i].to_i + values[i] if values[i]
        totals_sessions[i] += session
      end
    end

    g.minimum_value = 0

    labels = {}
    current_year = nil
    current_month = nil
    weeks.each_with_index do |week, i|
      year = week[0]
      month = Date.commercial(week[0], week[1], 2).mon
      next unless totals[i] && (current_month.nil? || ((month - current_month > 1) && [1, 8].include?(month)) || year != current_year)
      labels[i] = year != current_year ? "#{month}\n    #{year}" : month.to_s
      current_year = year
      current_month = month
    end
    g.labels = labels

    g.to_blob
  end

  def month_chart(year, month, size)
    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = "Oppmøte #{I18n.t(:date)[:month_names][month]} #{year}"
    g.title_font_size = 18
    g.legend_font_size = 14
    g.marker_font_size = 14
    g.colors = %w(blue orange black green)
    g.x_axis_label = 'Dag'
    first_date = Date.civil(year, month, 1)
    last_date = Date.civil(year, month, -1)
    attendances = Attendance.includes(:practice).references(:practices)
        .where('practices.year = ? AND practices.week >= ? AND practices.week <= ? AND attendances.status NOT IN (?)',
            year, first_date.cweek, last_date.cweek, Attendance::ABSENT_STATES)
        .to_a.select { |a| a.date >= first_date && a.date <= last_date && a.date <= Date.today }
    group_schedules = attendances.map(&:group_schedule).uniq
    groups = group_schedules.map(&:group).uniq.sort_by(&:from_age)
    dates = attendances.map(&:date).sort.uniq
    g.labels = Hash[*dates.map { |d| [d.day, d.day.to_s] }.flatten]
    groups.each do |group|
      values = dates.select { |d| group.group_schedules.map(&:weekday).include? d.cwday }
          .map { |d| [d.day, attendances.select { |a| a.group_schedule.group == group && a.date == d }.size] }
      values.map! { |k, v| [k, v.positive? ? v : nil] }
      g.dataxy(group.name, values, nil, group.color) if values.any? { |v| v }
    end
    g.y_axis_increment = 5 if g.maximum_value && g.maximum_value >= 10
    g.minimum_value = 0
    g.to_blob
  end

  def month_per_year_chart(month, size)
    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title_font_size = 18
    g.legend_font_size = 14
    g.marker_font_size = 14
    g.colors = %w(blue orange black green)
    g.y_axis_label = 'Oppmøte'
    g.x_axis_label = 'År'
    result = Attendance.connection.execute <<EOF
SELECT g.name, p.year as year, count(*) as count
FROM attendances a
  LEFT JOIN practices p ON p.id = a.practice_id
  LEFT JOIN group_schedules gs ON gs.id = p.group_schedule_id
  LEFT JOIN groups g ON g.id = gs.group_id
WHERE a.status NOT IN (#{Attendance::ABSENT_STATES.map { |s| "'#{s}'" }.join(',')})
  AND DATE_PART('month', date_trunc('week', (p.year || '-1-4')::date)::date + 7 * (p.week - 1) + gs.weekday) = #{month}
GROUP BY g.name, p.year
ORDER BY g.name, p.year
EOF
    years = result.map { |r| r['year'] }.sort.uniq
    g.title = "Oppmøte #{I18n.t(:date)[:month_names][month]} #{years[0]}-#{years[-1]}"
    result.group_by { |r| r['name'] }.each do |group, values|
      g.dataxy(group, values.map { |v| [v['year'], v['count']] }, nil, Group.find_by_name(group).color)
    end
    g.labels = Hash[*years.map { |y| [y, y.to_s] }.flatten]
    g.minimum_value = 0
    g.to_blob
  end
end
