class MemberGradeHistoryGraph
  ACTIVE_CLAUSE = '"EXISTS (SELECT id FROM attendances WHERE member_id = members.id AND (year > #{prev_date.cwyear} OR (year = #{prev_date.cwyear} AND week >= #{prev_date.cweek})) AND (year < #{next_date.cwyear} OR (year = #{next_date.cwyear} AND week <= #{next_date.cweek}))) AND (joined_on IS NULL OR joined_on <= \'#{date.strftime(\'%Y-%m-%d\')}\') AND (left_on IS NULL OR left_on > \'#{date.strftime(\'%Y-%m-%d\')}\')"'
  
  def self.history_graph(size = 480)
    begin
      require 'gruff'
    rescue MissingSourceFile => e
      return File.read("public/images/rails.png")
    end

    ranks = MartialArt.find_by_name('Kei Wa Ryu').ranks.reverse
    ranks = ranks.last(8) if Rails.env == 'production'

    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = "Fordeling av grader"
    g.font = '/usr/share/fonts/bitstream-vera/Vera.ttf'
    g.hide_dots = true
    g.colors = %w{yellow yellow orange orange green green yellow yellow orange orange green green blue blue brown yellow orange green blue brown black black black}[-ranks.size..-1].reverse
    
    #first_date = find(:first, :order => 'joined_on').joined_on
    #first_date = 5.years.ago.to_date
    first_date = Date.civil(2010, 8, 01)
    dates = []
    Date.today.step(first_date, -14){|date| dates << date}
    dates.reverse!
    sums = nil
    ranks.each do |rank|
      rank_totals = totals(rank, dates)
      if sums
        sums = sums.zip(rank_totals).map{|s, t| s + t}
      else
        sums = rank_totals
      end
      g.data(rank.name, sums)
    end

    g.minimum_value = 0
    
    labels = {}
    current_year = nil
    current_month = nil
    dates.each_with_index {|date, i| if date.month != current_month && [1,8].include?(date.month) then labels[i] = (date.year != current_year ? "#{date.strftime("%m")}\n    #{date.strftime("%Y")}" : "#{date.strftime("%m")}") ; current_year = date.year ; current_month = date.month end}
    g.labels = labels
      
    g.maximum_value = 25
    g.marker_count = 5
    g.to_blob
  end
    
  def self.totals(rank, dates)
    dates.each.map do |date|
      prev_date = date - 1.month
      next_date = date + 1.month
      active_members = Member.all(
          :select => (Member.column_names - ['image']).join(','),
        :conditions => eval(ACTIVE_CLAUSE),
        :include => {:graduates => {:graduation => :martial_art}}
      )
      ranks = active_members.select{|m| m.graduates.select{|g| g.graduation.martial_art.name =='Kei Wa Ryu' && g.graduation.held_on <= date}.sort_by{|g| g.graduation.held_on}.last.try(:rank) == rank}.size
      logger.debug "Active members: #{active_members.size}, ranks: #{ranks}"
      ranks
    end
  end

  def self.logger
    Rails.logger
  end
  
end
