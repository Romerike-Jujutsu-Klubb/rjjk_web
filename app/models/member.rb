# encoding: UTF-8
class Member < ActiveRecord::Base
  JUNIOR_AGE_LIMIT = 15
  ASPIRANT_AGE_LIMIT = 10
  MEMBERS_PER_PAGE = 30
  ACTIVE_CONDITIONS = 'left_on IS NULL or left_on > DATE(CURRENT_TIMESTAMP)'

  acts_as_gmappable :check_process => :prevent_geocoding, :validation => false

  def prevent_geocoding
    address.blank? || (!latitude.blank? && !longitude.blank?)
  end

  scope :active, lambda { |from_date, to_date = from_date| {:conditions => ['joined_on <= ? AND left_on IS NULL OR left_on > ?', to_date, from_date]} }

  belongs_to :image, :dependent => :destroy
  belongs_to :user, :dependent => :destroy
  has_one :nkf_member, :dependent => :nullify
  has_many :attendances, :dependent => :destroy
  has_many :censors, :dependent => :destroy
  has_many :correspondences, :dependent => :destroy
  has_many :graduates, :dependent => :destroy
  has_many :passed_graduates, :class_name => 'Graduate',
           :conditions => {:graduates => {:passed => true}}
  has_many :group_instructors, :dependent => :destroy
  has_many :ranks, :through => :passed_graduates
  has_many :signatures, :dependent => :destroy
  has_and_belongs_to_many :groups

  NILLABLE_FIELDS = [:parent_name, :phone_home, :phone_work]
  before_validation { NILLABLE_FIELDS.each { |f| self[f] = nil if self[f].blank? } }

  # validates_presence_of :address, :cms_contract_id
  validates_length_of :billing_postal_code, :is => 4, :if => Proc.new { |m| m.billing_postal_code && !m.billing_postal_code.empty? }
  validates_presence_of :birthdate, :joined_on
  validates_presence_of :user, :user_id, :unless => :left_on
  validates_uniqueness_of :cms_contract_id, :if => :cms_contract_id
  validates_presence_of :first_name, :last_name
  validates_inclusion_of :instructor, :in => [true, false]
  validates_inclusion_of :male, :in => [true, false]
  validates_inclusion_of :nkf_fee, :in => [true, false]
  validates_inclusion_of :payment_problem, :in => [true, false]
  #validates_presence_of :postal_code
  validates_length_of :postal_code, :is => 4, :if => Proc.new { |m| m.postal_code && !m.postal_code.empty? }
  validates_uniqueness_of :rfid, :if => Proc.new { |r| r.rfid and not r.rfid.empty? }

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
    search_fields = [
        :billing_email, :email, :first_name, :last_name, :parent_email,
        :parent_name, :phone_home, :phone_mobile, :phone_parent, :phone_work]
    all({
            :conditions => [search_fields.map { |c| "UPPER(#{c}) LIKE ?" }.join(' OR '), *(["%#{UnicodeUtils.upcase(query)}%"] * search_fields.size)],
            :order => 'first_name, last_name',
        }.update(options))
  end

  def self.instructors(date = Date.today)
    active(date).
        where('instructor = true OR id IN (SELECT member_id FROM group_instructors GROUP BY member_id)').
        order('first_name, last_name').all
  end

  def self.create_corresponding_user!(attrs)
    attrs.symbolize_keys!
    email, first_name, last_name = attrs[:email], attrs[:first_name], attrs[:last_name]
    passwd = (0..4).map { [*((0..9).to_a + ('a'..'z').to_a)][rand(36)] }.join

    # Full name and email
    full_email = %Q{"#{first_name} #{last_name}" <#{email}>}
    max_length = 64

    # First and last names only
    if full_email.size > max_length
      logger.debug "Full email too long: #{full_email}"
      full_email = %Q{"#{first_name.split(/\s+/).first} #{last_name.split(/\s+/).last}" <#{email}>}
    end

    # Squeezed name and full email
    if full_email.size > max_length
      logger.debug "Full email too long: #{full_email}"
      max_name_size = max_length - email.size - 5
      (cut_name = "#{first_name} #{last_name}")[(max_name_size / 2) - 2 .. (-max_name_size / 2)]
      full_email = %Q{"#{cut_name}" <#{email}>}
    end

    # Fallback to non-valid email...
    if full_email.size > max_length
      logger.debug "Full email too long: #{full_email}"
      (full_email = %Q{#{first_name} #{last_name} <#{email}>})[(max_length / 2) - 2 .. (-max_length / 2)]
    end

    potential_emails = [email, full_email]
    potential_emails.compact.each do |potential_email|
      existing_user = User.where('(login = ? OR email = ?) AND NOT EXISTS (SELECT id FROM members WHERE user_id = users.id)',
                                 potential_email, potential_email).first
      return existing_user if existing_user

      next if User.where('login = ? OR email = ?', *([potential_email] * 2)).exists?

      new_user = User.new(
          :login => potential_email, :first_name => first_name, :last_name => last_name,
          :email => potential_email, :password => passwd, :password_confirmation => passwd,
      )
      new_user.password_needs_confirmation = true
      new_user.save!

      return new_user
    end
    raise "Unable to create user for member (#{potential_emails}): #{attrs}"
  end

  # describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
  def gmaps4rails_address
    "#{self.address}, #{self.postal_code}, Norway"
  end

  def gmaps4rails_infowindow
    html = ''
    html << "<img src='/members/thumbnail/#{id}.#{image.format}' width='128' style='float: left; margin-right: 1em'>" if image?
    html<< name
    html
  end

  def current_graduate(martial_art, date = Date.today)
    graduates.select { |g| g.passed? && g.graduation.held_on < date && (martial_art.nil? || g.rank.martial_art_id == martial_art.id) }.sort_by { |g| g.rank.position }.last
  end

  def attendances_since_graduation(before_date = Date.today, group = nil)
    groups = group ? [group] : Group.all
    groups.map do |g|
      if (c = current_graduate(g.martial_art, before_date))
        ats = attendances.select { |a| a.date > c.graduation.held_on }
      else
        ats = attendances.to_a
      end
      ats.select! { |a| a.group_schedule.group == g && a.date <= before_date }
      ats
    end.flatten.sort_by(&:date).reverse
  end

  def current_rank(martial_art = nil, date = Date.today)
    current_graduate(martial_art, date).try(:rank)
  end

  def current_rank_date(martial_art = nil, date = Date.today)
    graduate = self.current_graduate(martial_art, date)
    graduate && graduate.graduation.held_on || joined_on
  end

  def current_rank_age(martial_art, to_date)
    date = current_rank_date(martial_art, to_date)
    days = (to_date - date).to_i
    years = (to_date - date).to_i / 365
    months = (days - (years * 365)) / 30
    [years > 0 ? "#{years} år" : nil, years == 0 || months > 0 ? "#{months} mnd" : nil].compact.join(' ')
  end

  def next_rank(graduation = Graduation.new(:held_on => Date.today))
    age = self.age(graduation.held_on)
    ma = graduation.group.try(:martial_art) || MartialArt.find_by_name('Kei Wa Ryu')
    current_rank = current_rank(ma, graduation.held_on)
    if current_rank
      next_rank = ma.ranks.find { |r|
        !future_ranks(graduation.held_on, ma).include?(r) &&
            r.position > current_rank.position &&
            age >= r.minimum_age &&
            (r.group.from_age..r.group.to_age).include?(age) &&
            attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
      }
      next_rank ||= ma.ranks.find { |r|
        !future_ranks(graduation.held_on, ma).include?(r) &&
            r.position > current_rank.position &&
            age >= r.minimum_age &&
            age >= r.group.from_age &&
            attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
      }
      next_rank ||= Rank.first(:conditions => ['martial_art_id = ? AND position = ?', ma, current_rank.position + 1])
    end
    next_rank ||= ma.ranks.find { |r|
      !future_ranks(graduation.held_on, ma).include?(r) &&
          age >= r.minimum_age &&
          (r.group.from_age..r.group.to_age).include?(age) &&
          attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
    }
    next_rank ||= ma.ranks.find { |r|
      !future_ranks(graduation.held_on, ma).include?(r) &&
          age >= r.minimum_age &&
          attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
    }
    next_rank ||= ma.ranks.find { |r| age.nil? || (age >= r.minimum_age && (r.group.from_age..r.group.to_age).include?(age)) }
    next_rank ||= ma.ranks.first
    next_rank
  end

  def future_graduates(after, martial_art_id)
    graduates.select { |g| g.passed? && g.graduation.group.martial_art_id == martial_art_id && g.graduation.held_on > after }
  end

  def future_ranks(after, martial_art_id)
    future_graduates(after, martial_art_id).map(&:rank)
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

  def active?
    !passive?
  end

  def passive?(date = Date.today, group = nil)
    nkf_member.medlemsstatus == 'P' ||
        (joined_on < 2.months.ago.to_date &&
            attendances.select { |a| (group.nil? || a.group_schedule.group_id == group.id) && a.date <= (date + 31) && a.date > (date - 92) }.empty?)
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

  def age(date = Date.today)
    return nil unless birthdate
    age = date.year - birthdate.year
    age -= 1 if date < birthdate + age.years
    age
  end

  def age_group
    return nil unless age
    if age >= JUNIOR_AGE_LIMIT
      'Senior'
    else
      'Junior'
    end
  end

  def gender
    if male
      'Mann'
    else
      'Kvinne'
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def image_file=(file)
    return if file.blank?
    self.create_image! :user_id => user_id, :name => file.original_filename,
                       :content_type => file.content_type, :content_data => file.read
  end

  def image?
    !!image_id
  end

  def thumbnail(x = 120, y = 160)
    return unless self.image?
    magick_image = Magick::Image.from_blob(Image.with_image.find(self.image_id).content_data).first
    return magick_image.crop_resized(x, y).to_blob
  end

  def cms_member
    CmsMember.find_by_cms_contract_id(cms_contract_id)
  end

  def invoice_email
    billing_email || email
  end

  def emails
    emails = [%Q{"#{name}" <#{email}>}]
    if billing_email
      emails << (parent_name ? %Q{"#{parent_name}" <#{billing_email}>} : billing_email)
    end
    if parent_email
      emails << (parent_2_name ? %Q{"#{parent_2_name}" <#{parent_email}>} : parent_email)
    end
    emails.uniq
  end

  def title(date = Date.today)
    current_rank(MartialArt.find_by_name('Kei Wa Ryu'), date).name =~ /dan/ ? 'Sensei' : 'Sempai'
  end
end
