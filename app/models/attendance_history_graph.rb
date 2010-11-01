class AttendanceHistoryGraph
  def initialize()
  end

  def logger
    Rails.logger
  end

  def history_graph(size = 480)
    begin
      require 'gruff'
    rescue MissingSourceFile => e
      return File.read("public/images/rails.png")
    end
    
    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = "Oppmøte"
    g.font = '/usr/share/fonts/bitstream-vera/Vera.ttf'
    #g.legend_font_size = 14
    g.hide_dots = true
    g.colors = %w{darkblue blue lightblue green orange red black}
    
    #first_date = find(:first, :order => 'joined_on').joined_on
    #first_date = 5.years.ago.to_date
    first_date = Date.civil(2007, 1, 01)
    weeks = []
    Date.today.step(first_date, -28){|date| weeks << [date.cwyear, date.cweek]}
    weeks.reverse!
    totals = Array.new(weeks.size - 1, nil)
    totals_sessions = Array.new(weeks.size - 1, 0)
    Group.all(:order => 'martial_art_id, from_age DESC').each do |group|
      attendances = weeks.each_cons(2).map{|w1, w2| Attendance.by_group_id(group.id).all(:conditions => ['(year > ? OR (year = ? AND week > ?)) AND (year < ? OR (year = ? AND week <= ?))', w1[0], w1[0], w1[1], w2[0], w2[0], w2[1]])}
      sessions = attendances.map{|ats| ats.map{|a| [a.group_schedule_id, a.year, a.week]}.uniq.size}
      values = attendances.each_with_index.map{|a, i| sessions[i] > 0 ? a.size / sessions[i] : nil}
      if values.any?{|v| v}
        g.data(group.name, values)
        sessions.each_with_index do |session, i|
          totals[i] = totals[i].to_i + values[i] if values[i]
          totals_sessions[i] += session
        end
        g.maximum_value = [g.maximum_value, values.compact.max].max
      end
    end

    # averages = totals.each_with_index.map{|t, i| totals_sessions[i] > 0 ? t / totals_sessions[i] : nil}
    # g.data("Gjennomsnitt", averages)
    # g.data("Totalt", totals)
    
    g.minimum_value = 0
    
    labels = {}
    current_year = nil
    current_week = nil
    weeks.each_with_index do |week, i|
      if totals[i] && (current_week.nil? || (week[1] != current_week && [1,27].include?(week[1]))  || week[0] != current_year)
        labels[i] = week[0] != current_year ? "#{week[1]}\n    #{week[0]}" : week[1].to_s
        current_year = week[0]
        current_week = week[1]
      end
    end
    g.labels = labels
      
    # g.draw_vertical_legend
      
    g.maximum_value = g.maximum_value + 10 - g.maximum_value % 10
    g.marker_count = g.maximum_value / 10
    g.to_blob
  end
    
end
