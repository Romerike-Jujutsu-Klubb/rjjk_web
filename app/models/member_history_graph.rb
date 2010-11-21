class MemberHistoryGraph
  JUNIOR_AGE_LIMIT = 15
  ASPIRANT_AGE_LIMIT = 10
  ACTIVE_CLAUSE = '"nkf_members.kontraktsbelop > 0 AND (joined_on IS NULL OR joined_on <= \'#{date.strftime(\'%Y-%m-%d\')}\') AND (left_on IS NULL OR left_on > \'#{date.strftime(\'%Y-%m-%d\')}\')"'
  
  def self.history_graph(size = 480)
    begin
      require 'gruff'
    rescue MissingSourceFile => e
      return File.read("public/images/rails.png")
    end
    
    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = "Antall aktive medlemmer"
    g.font = '/usr/share/fonts/bitstream-vera/Vera.ttf'
    #g.legend_font_size = 14
    g.hide_dots = true
    g.colors = %w{black blue lightblue green orange red}
    
    #first_date = find(:first, :order => 'joined_on').joined_on
    #first_date = 5.years.ago.to_date
    first_date = Date.civil(2007, 01, 01)
    dates = []
    Date.today.step(first_date, -14) {|date| dates << date}
    dates.reverse!
    others = dates.map {|date| Member.count(:conditions => "(#{eval ACTIVE_CLAUSE}) AND birthdate IS NULL", :joins => :nkf_member)}
    0.upto(others.size){|i| others[i] = nil if others[i] == 0 && others[i - 1].to_i == 0}
    g.data("Totalt", totals(dates))
    g.data("Aikido Seniorer", seniors_ad(dates))
    g.data("Aikido Juniorer", juniors_ad(dates))
    g.data("Grizzly", seniors_jj(dates))
    g.data("Tiger", juniors_jj(dates))
    g.data("Panda", aspirants(dates))
    g.data("Uten fødselsdato", others)
    
    g.minimum_value = 0
    
    labels = {}
    current_year = nil
    current_month = nil
    dates.each_with_index {|date, i| if date.month != current_month && [1,8].include?(date.month) then labels[i] = (date.year != current_year ? "#{date.strftime("%m")}\n    #{date.strftime("%Y")}" : "#{date.strftime("%m")}") ; current_year = date.year ; current_month = date.month end}
    g.labels = labels
      
    # g.draw_vertical_legend
      
    precision = 1
    g.maximum_value = (g.maximum_value.to_s[0..precision].to_i + 1) * (10**(Math::log10(g.maximum_value.to_i).to_i - precision)) if g.maximum_value > 0
    g.maximum_value = [100, g.maximum_value].max
    g.marker_count = g.maximum_value / 10
    g.to_blob
  end
    
  def self.totals(dates)
    dates.map {|date| Member.count(:conditions => eval(ACTIVE_CLAUSE), :joins => :nkf_member)}
  end
    
  def self.seniors_jj(dates)
    dates.map {|date| Member.count(
        :conditions => "(#{eval ACTIVE_CLAUSE}) AND birthdate IS NOT NULL AND birthdate < '#{self.senior_birthdate(date)}' AND (martial_arts.name IS NULL OR martial_arts.name <> 'Aikikai')",
        :include => {:groups => :martial_art},
        :joins => :nkf_member
    )}
  end

  def self.juniors_jj(dates)
    dates.map {|date| Member.count(
        :conditions => ["(#{eval ACTIVE_CLAUSE}) AND birthdate IS NOT NULL AND birthdate BETWEEN ? AND ? AND (martial_arts.name IS NULL OR martial_arts.name <> 'Aikikai')", self.senior_birthdate(date), self.junior_birthdate(date)],
        :include => {:groups => :martial_art},
        :joins => :nkf_member
    )}
  end
  
  def self.seniors_ad(dates)
    dates.map {|date| Member.count(
        :conditions => "(#{eval ACTIVE_CLAUSE}) AND birthdate IS NOT NULL AND birthdate < '#{self.senior_birthdate(date)}' AND martial_arts.name = 'Aikikai'",
        :include => {:groups => :martial_art},
        :joins => :nkf_member
    )}
  end
  
  def self.juniors_ad(dates)
    dates.map {|date| Member.count(
        :conditions => "(#{eval ACTIVE_CLAUSE}) AND birthdate IS NOT NULL AND birthdate >= '#{self.senior_birthdate(date)}' AND martial_arts.name = 'Aikikai'",
        :include => {:groups => :martial_art},
        :joins => :nkf_member
    )}
  end
  
  def self.aspirants(dates)
    dates.map {|date| Member.count(
        :conditions => "(#{eval ACTIVE_CLAUSE}) AND birthdate IS NOT NULL AND birthdate >= '#{self.junior_birthdate(date)}'",
        :joins => :nkf_member
    )}
  end
  
  def self.was_senior?(date)
    birthdate.nil? or ((date - birthdate) / 365) > JUNIOR_AGE_LIMIT
  end
    
  def self.senior_birthdate(date)
    date - JUNIOR_AGE_LIMIT.years
  end
    
  def self.junior_birthdate(date)
    date - ASPIRANT_AGE_LIMIT.years
  end
    
end
