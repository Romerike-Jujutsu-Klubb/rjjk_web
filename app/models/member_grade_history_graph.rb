class MemberGradeHistoryGraph
  ACTIVE_CLAUSE = '"(joined_on IS NULL OR joined_on <= \'#{date.strftime(\'%Y-%m-%d\')}\') AND (left_on IS NULL OR left_on > \'#{date.strftime(\'%Y-%m-%d\')}\')"'
  
  def self.history_graph(size = 480)
    begin
      require 'gruff'
    rescue MissingSourceFile => e
      return File.read("public/images/rails.png")
    end
    
    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = "Fordeling av grader"
    g.font = '/usr/share/fonts/bitstream-vera/Vera.ttf'
    g.hide_dots = true
    g.colors = %w{yellow yellow orange orange green green yellow yellow orange orange green green blue blue brown yellow orange green blue brown black black black}[-8..-1]
    
    #first_date = find(:first, :order => 'joined_on').joined_on
    #first_date = 5.years.ago.to_date
    first_date = Date.civil(2007, 01, 01)
    dates = []
    Date.today.step(first_date, -14) {|date| dates << date}
    dates.reverse!
    MartialArt.find_by_name('Kei Wa Ryu').ranks[-8..-1].each do |rank|
      g.data(rank.name, totals(rank, dates))
    end

    g.minimum_value = 0
    
    labels = {}
    current_year = nil
    current_month = nil
    dates.each_with_index {|date, i| if date.month != current_month && [1,8].include?(date.month) then labels[i] = (date.year != current_year ? "#{date.strftime("%m")}\n    #{date.strftime("%Y")}" : "#{date.strftime("%m")}") ; current_year = date.year ; current_month = date.month end}
    g.labels = labels
      
    precision = 1
    g.maximum_value = (g.maximum_value.to_s[0..precision].to_i + 1) * (10**(Math::log10(g.maximum_value.to_i).to_i - precision)) if g.maximum_value > 0
    g.maximum_value = [10, g.maximum_value].max
    g.marker_count = g.maximum_value / 10
    g.to_blob
  end
    
  def self.totals(rank, dates)
    dates.map do |date|
      active_members = Member.all(
          :select => (Member.column_names - ['image']).join(','),
        :conditions => eval(ACTIVE_CLAUSE),
        :include => {:graduates => {:graduation => :martial_art}}
      )
      ranks = active_members.select{|m| m.graduates.select{|g| g.graduation.martial_art.name =='Kei Wa Ryu'}.sort_by{|g| g.graduation.held_on}.last.try(:rank) == rank}.size
      logger.debug "Active members: #{active_members.size}, ranks: #{ranks}"
      ranks
    end
  end

  def self.logger
    Rails.logger
  end
  
end
