class Member < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :address, :postal_code
  #validates_presence_of :birthdate, :join_on
  validates_inclusion_of(:payment_problem, :in => [true, false])
  validates_inclusion_of(:male, :in => [true, false])
  
  def self.find_active()
    Member.find(:all, :conditions => "left_on IS NULL", :order => 'last_name, first_name')
  end
  
  def fee
    if instructor?
      0
    elsif senior?
      300 + nkf_fee
    else
      260 + nkf_fee
    end
  end
  
  def nkf_fee
    if senior?
     (nkf_fee? ? (279.0 / 12).ceil : 0)
    else
     (nkf_fee? ? (155.0 / 12).ceil : 0)  
    end
  end
  
  def self.history_graph
    size = 640
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
    #g.colors = %w{blue orange}

    #first_date = find(:first, :order => 'joined_on').joined_on
    first_date = Date.today - (3 * 12 * 30)
    dates = []
    first_date.step(Date.today, 30) {|date| dates << date}
    active_clause = '"joined_on <= \'#{date.strftime(\'%Y-%m-%d\')}\' AND (left_on IS NULL OR left_on > \'#{date.strftime(\'%Y-%m-%d\')}\')"'
    totals = dates.map {|date| Member.count(:conditions => eval(active_clause))}
    juniors = dates.map {|date| Member.count(:conditions => "(#{eval active_clause}) AND birtdate IS NULL OR birtdate >= '#{self.senior_birthdate(date)}'")}
    seniors = dates.map {|date| Member.count(:conditions => "(#{eval active_clause}) AND birtdate IS NOT NULL AND birtdate < '#{self.senior_birthdate(date)}'")}
    g.data("Totalt", totals)
    g.data("Junior", juniors)
    g.data("Senior", seniors)
    
    g.minimum_value = 0
    
    labels = {}
    current_year = nil
    dates.each_with_index {|date, i| if i % 2 == 0 then labels[i] = date.strftime("%m#{"\n%Y" if date.year != current_year}") ; current_year = date.year end}
    g.labels = labels
    
    # g.draw_vertical_legend
    
    #g.maximum_value = (g.maximum_value.to_s[0..0].to_i + 1) * (10**Math::log10(g.maximum_value.to_i).to_i) if g.maximum_value > 0
    g.to_blob
  end

  def self.was_senior?(date)
    birthdate.nil? or ((date - birthdate) / 365) > 15
  end

  def self.senior_birthdate(date)
    date - (15 * 365)
  end

end
