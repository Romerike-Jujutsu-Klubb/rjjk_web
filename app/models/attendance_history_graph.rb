# encoding: UTF-8

class AttendanceHistoryGraph
  def logger
    Rails.logger
  end

  def history_graph(size = 480)
    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = 'Oppmøte'
    g.title_font_size = 18
    g.legend_font_size = 14
    #g.font = '/usr/share/fonts/bitstream-vera/Vera.ttf'
    #g.legend_font_size = 14
    g.hide_dots = true
    g.colors = %w{blue orange black green}
    #g.y_axis_label = 'Oppmøte'
    #g.x_axis_label = 'År / Måned'
    g.x_axis_label=''
    g.y_axis_increment = 5
    #first_date = find(:first, :order => 'joined_on').joined_on
    #first_date = 5.years.ago.to_date
    first_date = Date.civil(2010, 8, 01)
    weeks = []
    Date.today.step(first_date, -28) { |date| weeks << [date.cwyear, date.cweek] }
    weeks.reverse!
    totals = Array.new(weeks.size - 1, nil)
    totals_sessions = Array.new(weeks.size - 1, 0)
    Group.all(:order => 'martial_art_id, from_age DESC, to_age').each do |group|
      attendances = weeks.each_cons(2).map do |w1, w2|
        Attendance.by_group_id(group.id).all(:conditions => ['(year > ? OR (year = ? AND week > ?)) AND (year < ? OR (year = ? AND week <= ?))', w1[0], w1[0], w1[1], w2[0], w2[0], w2[1]]) +
            TrialAttendance.by_group_id(group.id).all(:conditions => ['(year > ? OR (year = ? AND week > ?)) AND (year < ? OR (year = ? AND week <= ?))', w1[0], w1[0], w1[1], w2[0], w2[0], w2[1]])
      end
      sessions = attendances.map { |ats| ats.map { |a| [a.group_schedule_id, a.year, a.week] }.uniq.size }
      values = attendances.each_with_index.map { |a, i| sessions[i] > 0 ? a.size / sessions[i] : nil }
      if values.any? { |v| v }
        g.data(group.name, values)
        sessions.each_with_index do |session, i|
          totals[i] = totals[i].to_i + values[i] if values[i]
          totals_sessions[i] += session
        end
        #g.maximum_value = [g.maximum_value, values.compact.max].max
      end
    end

    # averages = totals.each_with_index.map{|t, i| totals_sessions[i] > 0 ? t / totals_sessions[i] : nil}
    # g.data("Gjennomsnitt", averages)
    # g.data("Totalt", totals)

    g.minimum_value = 0

    labels = {}
    current_year = nil
    current_month = nil
    weeks.each_with_index do |week, i|
      year = week[0]
      month = Date.commercial(week[0], week[1], 2).mon
      if totals[i] && (current_month.nil? || ((month - current_month > 1) && [1, 8].include?(month)) || year != current_year)
        labels[i] = year != current_year ? "#{month}\n    #{year}" : month.to_s
        current_year = year
        current_month = month
      end
    end
    g.labels = labels

    # g.draw_vertical_legend

    #g.maximum_value ||= 0
    #g.maximum_value = g.maximum_value + 10 - g.maximum_value % 10
    #g.marker_count = g.maximum_value / 5
    g.to_blob
  end

  def month_chart(year, month, size)
    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = "Oppmøte #{I18n.t(:date)[:month_names][month]} #{year}"
    g.title_font_size = 18
    g.legend_font_size = 14
    g.colors = %w{blue orange black green}
    #g.y_axis_label = 'Oppmøte'
    g.x_axis_label='Dag'
    first_date = Date.civil(year, month, 1)
    last_date = Date.civil(year, month, -1)
    attendances = Attendance.
        where('year = ? AND week >= ? AND week <= ? AND status NOT IN (?)', year, first_date.cweek, last_date.cweek, Attendance::ABSENT_STATES).
        all.select { |a| a.date >= first_date && a.date <= last_date }
    group_schedules = attendances.map(&:group_schedule).uniq
    groups = group_schedules.map(&:group).uniq.sort_by(&:from_age)
    dates = (first_date..last_date).select { |d| group_schedules.any? { |gs| gs.weekday == d.cwday } }
    g.labels = Hash[*dates.map { |d| [d.day, d.day.to_s] }.flatten]
    groups.each do |group|
      values = dates.select { |d| group.group_schedules.map(&:weekday).include? d.cwday }.
          map { |d| [d.day, attendances.select { |a| a.group_schedule.group == group && a.date == d }.size] }
      values.map! { |k, v| [k, v > 0 ? v : nil] }
      if values.any? { |v| v }
        g.dataxy(group.name, values, nil, group.color)
      end
    end
    g.y_axis_increment = 5 if g.maximum_value >= 10
    g.minimum_value = 0
    g.to_blob
  end

end
