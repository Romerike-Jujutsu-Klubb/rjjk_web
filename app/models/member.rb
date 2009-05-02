class Member < ActiveRecord::Base
  JUNIOR_AGE_LIMIT = 15
  ASPIRANT_AGE_LIMIT = 10
  MEMBERS_PER_PAGE = 30
  ACTIVE_CONDITIONS = "left_on IS NULL or left_on > DATE(CURRENT_TIMESTAMP)"
  
  has_many :graduates
  has_many :attendances
  has_and_belongs_to_many :groups
  has_one :nkf_member
  
  # validates_presence_of :address, :cms_contract_id
  validates_length_of :billing_postal_code, :is => 4, :if => Proc.new{|m|m.billing_postal_code && !m.billing_postal_code.empty?}
  # validates_presence_of :birthdate, :join_on
  validates_uniqueness_of :cms_contract_id, :if => :cms_contract_id
  validates_presence_of :first_name, :last_name
  validates_inclusion_of :instructor, :in => [true, false]
  validates_inclusion_of :male, :in => [true, false]
  validates_inclusion_of :nkf_fee, :in => [true, false]
  validates_inclusion_of :payment_problem, :in => [true, false]
  validates_presence_of :postal_code
  validates_length_of :postal_code, :is => 4, :if => Proc.new {|m|m.postal_code && !m.postal_code.empty?}
  validates_uniqueness_of :rfid, :if => Proc.new{|r| r.rfid and not r.rfid.empty?}
  
  def self.find_active
    find(:all, :conditions => ACTIVE_CONDITIONS, :order => 'last_name, first_name')
  end
  
  def self.paginate_active(page)
    paginate :page => page, :per_page => MEMBERS_PER_PAGE, :conditions => ACTIVE_CONDITIONS, :order => 'first_name, last_name'
  end
  
  def self.count_active
    count :conditions => ACTIVE_CONDITIONS 
  end

  def self.find_by_contents(query, options = {})
    find(:all, {
      :conditions => ['UPPER(first_name) LIKE ? OR UPPER(last_name) LIKE ?', *([query.upcase] * 2)],
      :order => 'first_name, last_name',
    }.update(options))
  end
  
  def current_graduate(martial_art)
    graduates.select{|g|martial_art.nil? || g.rank.martial_art == martial_art}.sort_by {|g| g.graduation.held_on}.last
  end
  
  def current_rank(martial_art = nil)
    graduate = self.current_graduate(martial_art)
    graduate && graduate.rank
  end
  
  def current_rank_date(martial_art = nil)
    graduate = self.current_graduate(martial_art)
    graduate && graduate.graduation.held_on || joined_on
  end

  def current_rank_age(martial_art = nil)
    date = current_rank_date
    days = (Date.today - date).to_i
    years = (Date.today - date).to_i / 365
    months = (days - (years * 365)) / 30
    "#{"#{years} år" if years > 0} #{"#{months} mnd" if years == 0 || months > 0}" # TODO: What about leap years etc?
  end
    
  def fee
    if instructor?
      0
    elsif senior?
      300 + nkf_fee_amount
    else
      260 + nkf_fee_amount
    end
  end
  
  def senior?
    birthdate && (age >= JUNIOR_AGE_LIMIT)
  end
  
  def nkf_fee_amount
    if senior?
     (nkf_fee? ? (279.0 / 12).ceil : 0)
    else
     (nkf_fee? ? (155.0 / 12).ceil : 0)  
    end
  end
  
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
    g.colors = %w{blue blue green orange red}
    
    #first_date = find(:first, :order => 'joined_on').joined_on
    #first_date = 5.years.ago.to_date
    first_date = Date.civil(2007, 01, 01)
    dates = []
    Date.today.step(first_date, -14) {|date| dates << date}
    dates.reverse!
    active_clause = '"(joined_on IS NULL OR joined_on <= \'#{date.strftime(\'%Y-%m-%d\')}\') AND (left_on IS NULL OR left_on > \'#{date.strftime(\'%Y-%m-%d\')}\')"'
    totals = dates.map {|date| Member.count(:conditions => eval(active_clause))}
    seniors = dates.map {|date| Member.count(:conditions => "(#{eval active_clause}) AND birthdate IS NOT NULL AND birthdate < '#{self.senior_birthdate(date)}'")}
    juniors = dates.map {|date| Member.count(:conditions => ["(#{eval active_clause}) AND birthdate IS NOT NULL AND birthdate BETWEEN ? AND ?", self.senior_birthdate(date), self.junior_birthdate(date)])}
    aspirants = dates.map {|date| Member.count(:conditions => "(#{eval active_clause}) AND birthdate IS NOT NULL AND birthdate >= '#{self.junior_birthdate(date)}'")}
    others = dates.map {|date| Member.count(:conditions => "(#{eval active_clause}) AND birthdate IS NULL")}
    g.data("Totalt", totals)
    g.data("Senior", seniors)
    g.data("Junior", juniors)
    g.data("Aspiranter", aspirants)
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
      g.marker_count = g.maximum_value / 10
      g.to_blob
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
    
    def age
      birthdate && ((Date.today - birthdate).to_i / 365) # TODO: What about leap years?
    end
    
    def age_group
      return nil unless age
      if age >= JUNIOR_AGE_LIMIT
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
    
    def image_file=(file)
      return if file == ""
      self.image = file.read
      self.image_name = file.original_filename
      self.image_content_type = file.content_type
    end
    
    def image_format
      image_name && image_name.split('.').last
    end

    def thumbnail(x = 120, y = 160)
      return unless self.image
      magick_image = Magick::Image.from_blob(self.image).first
      return magick_image.crop_resized(x, y).to_blob
    end

    def cms_member
      CmsMember.find_by_cms_contract_id(cms_contract_id)
    end
    
  end
