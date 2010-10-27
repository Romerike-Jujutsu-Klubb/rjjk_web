class AttendanceHistoryGraph
  def initialize()
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
    first_date = Date.civil(2007, 01, 01)
    weeks = []
    Date.today.step(first_date, -7) {|date| weeks << [date.cwyear, date.cweek]}
    weeks.reverse!
    totals = Array.new(weeks.size, 0)
    Group.all.each do |group|
      values = weeks.map{|w| Attendance.by_group_id(group.id).find_all_by_year_and_week(w[0], w[1]).size}
      g.data(group.name, values)
      (0...weeks.size).each do |i|
        totals[i] += values[i]
      end
    end

    g.data("Totalt", totals)
    
    g.minimum_value = 0
    
    labels = {}
    current_year = nil
    current_week = nil
    weeks.each_with_index {|week, i| if week[1] != current_week && [1,27].include?(week[1]) then labels[i] = (week[0] != current_year ? "#{week[1]}\n    #{week[0]}" : "#{week[1]}") ; current_year = week[0] ; current_week = week[1] end}
    g.labels = labels
      
    # g.draw_vertical_legend
      
    precision = 1
    # g.maximum_value = (g.maximum_value.to_s[0..precision].to_i + 1) * (10**(Math::log10(g.maximum_value.to_i).to_i - precision)) if g.maximum_value > 0
    g.maximum_value = [10, (totals.max / 10) * 10].max
    g.marker_count = g.maximum_value / 10
    g.to_blob
  end
    
end
