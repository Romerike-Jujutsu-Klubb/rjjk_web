class NkfMember < ActiveRecord::Base
  FIELD_MAP = {
      :adresse_1 => nil,
      :adresse_2 => :address,
      :adresse_3 => nil,
      :antall_etiketter_1 => nil,
      :betalt_t_o_m__dato => nil,
      :created_at => nil,
      :epost => :email,
      :epost_faktura => nil,
      :etternavn => :last_name,
      :fodselsdato => :birthdate,
      :fornavn => :first_name,
      :gren_stilart_avd_parti___gren_stilart_avd_parti => nil,
      :hovedmedlem_id => nil,
      :hovedmedlem_navn => nil,
      :id => nil,
      :innmeldtarsak => nil,
      :innmeldtdato => :joined_on,
      :kjonn => :male,
      :klubb => nil,
      :klubb_id => nil,
      :konkurranseomrade_id => nil,
      :konkurranseomrade_navn => nil,
      :kont_belop => nil,
      :kont_sats => nil,
      :kontraktsbelop => nil,
      :kontraktstype => nil,
      :medlemskategori => nil,
      :medlemskategori_navn => nil,
      :medlemsnummer => nil,
      :medlemsstatus => nil,
      :member_id => nil,
      :mobil => :phone_mobile,
      :postnr => :postal_code,
      :rabatt => nil,
      :sist_betalt_dato => nil,
      :sted => nil,
      :telefon => :phone_home,
      :telefon_arbeid => :phone_work,
      :updated_at => nil,
      :utmeldtarsak => nil,
      :utmeldtdato => :left_on,
      :ventekid => nil,
      :yrke => nil,
  }

  belongs_to :member

  validates_presence_of :kjonn
  validates_uniqueness_of :member_id, :allow_nil => true

  def self.find_free_members
    Member.all(
        :conditions => "(left_on IS NULL OR left_on >= '2009-01-01') AND id NOT IN (SELECT member_id FROM nkf_members WHERE member_id IS NOT NULL)",
        :order => 'first_name, last_name'
    )
  end

  def converted_attributes
    new_attributes = {}
    attributes.each do |k, v|
      if FIELD_MAP.keys.include?(k.to_sym)
        if FIELD_MAP[k.to_sym]
          if v =~ /^\s*(\d{2}).(\d{2}).(\d{4})\s*$/
            v = "#$3-#$2-#$1"
          elsif v =~ /Mann|Kvinne/
            v = v == 'Mann'
          end
          new_attributes[FIELD_MAP[k.to_sym]] = v
        else
          # Ignoring attribute
        end
      else
        logger.error "Unknown attribute: #{k}"
      end
    end
    new_attributes
  end

  def create_corresponding_member!
    p = (0..4).map { [*((0..9).to_a + ('a'..'z').to_a)][rand(36)] }.join
    transaction do
      u = User.find_by_email(epost)
      if u.nil? || Member.exists?(:user_id => u.id)
        if u
          email = %Q{#{fornavn} #{etternavn} <#{epost}>}
          if email.size > 40
            email = %Q{#{fornavn.split(/\s+/).first} #{etternavn.split(/\s+/).last} <#{epost}>}[0..39]
          end
        else
          email = epost
        end
        u = User.new(
            :login => email, :first_name => fornavn, :last_name => etternavn,
            :email => email, :password => p, :password_confirmation => p,
        )
        u.password_needs_confirmation = true
        u.save!
      end
      member = create_member!(
          converted_attributes.update :instructor => false, :nkf_fee => true,
                                      :payment_problem => false, :user => u
      )
      member.nkf_member = self
      member
    end
  end

end
