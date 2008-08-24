class Member < ActiveRecord::Base
  DEPARTMENTS = ['Jujutsu', 'Aikido']
  MEMBERS_PER_PAGE = 30
  ACTIVE_CONDITIONS = "left_on IS NULL or left_on > DATE(CURRENT_TIMESTAMP)"
    

  acts_as_ferret :fields => [:first_name,:last_name,:address,:postal_code,
                             :email, :phone_home, :phone_work, 
                             :phone_mobile, :phone_parent, :department, 
                             :billing_type, :comment]
  
  has_many :graduates

  validates_presence_of :first_name, :last_name, :address, :postal_code, :cms_contract_id
  #validates_presence_of :birthdate, :join_on
  validates_inclusion_of(:payment_problem, :in => [true, false])
  validates_inclusion_of(:male, :in => [true, false])
  validates_length_of :postal_code, :is => 4
  validates_length_of :billing_postal_code, :is => 4, :if => :billing_postal_code
  validates_uniqueness_of :cms_contract_id
  
  def self.find_active
    Member.find(:all, :conditions => ACTIVE_CONDITIONS, :order => 'last_name, first_name')
  end
  
  def self.paginate_active(page)
    paginate :page => page, :per_page => MEMBERS_PER_PAGE, :conditions => ACTIVE_CONDITIONS, :order => 'last_name'
  end
  
  def self.count_active
    count :conditions => ACTIVE_CONDITIONS 
  end
  
  def current_grade
    @grade = graduates.sort_by {|g| g.graduation.held_on}.last
    if !@grade
      if senior?
        if department == "Jujutsu"
          "5.kyu"
        else
          "6.kyu"
      end
    else
      "10.mon"
      end
    else
      @grade.rank.name
    end
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
    size = 480
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
    g.colors = %w{green blue orange red}

    first_date = find(:first, :order => 'joined_on').joined_on
    #first_date = Date.today - (8 * 12 * 30)
    dates = []
    Date.today.step(first_date, -14) {|date| dates << date}
    dates.reverse!
    active_clause = '"(joined_on IS NULL OR joined_on <= \'#{date.strftime(\'%Y-%m-%d\')}\') AND (left_on IS NULL OR left_on > \'#{date.strftime(\'%Y-%m-%d\')}\')"'
    totals = dates.map {|date| Member.count(:conditions => eval(active_clause))}
    seniors = dates.map {|date| Member.count(:conditions => "(#{eval active_clause}) AND birtdate IS NOT NULL AND birtdate < '#{self.senior_birthdate(date)}'")}
    juniors = dates.map {|date| Member.count(:conditions => "(#{eval active_clause}) AND birtdate IS NOT NULL AND birtdate >= '#{self.senior_birthdate(date)}'")}
    others = dates.map {|date| Member.count(:conditions => "(#{eval active_clause}) AND birtdate IS NULL")}
    g.data("Totalt", totals)
    g.data("Senior", seniors)
    g.data("Junior", juniors)
    g.data("Andre", others)
    
    g.minimum_value = 0
    
    labels = {}
    current_year = nil
    current_month = nil
    dates.each_with_index {|date, i| if date.month != current_month && [1,8].include?(date.month) then labels[i] = (date.year != current_year ? "#{date.strftime("%m")}\n    #{date.strftime("%Y")}" : "#{date.strftime("%m")}") ; current_year = date.year ; current_month = date.month end}
    g.labels = labels
    
    # g.draw_vertical_legend
    
    g.maximum_value = (g.maximum_value.to_s[0..0].to_i + 1) * (10**Math::log10(g.maximum_value.to_i).to_i) if g.maximum_value > 0
    g.marker_count = g.maximum_value / 10
    g.to_blob
  end

  def self.was_senior?(date)
    birthdate.nil? or ((date - birthdate) / 365) > 15
  end

  def self.senior_birthdate(date)
    date - (15 * 365)
  end
  
  def age_group    
    if senior
      "Senior"
    else
      "Junior"
    end
  end
  
  def gender    
    if male
      "Mann"
    else
      "Kvinne"
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

end
