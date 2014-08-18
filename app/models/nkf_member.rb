class NkfMember < ActiveRecord::Base
  FIELD_MAP = {
      :adresse_1 => nil,
      :adresse_2 => :address,
      :adresse_3 => nil,
      :antall_etiketter_1 => nil,
      :betalt_t_o_m__dato => nil,
      :created_at => nil,
      :epost => :email,
      :epost_faktura => :billing_email,
      :etternavn => :last_name,
      :fodselsdato => :birthdate,
      :foresatte => :parent_name,
      :foresatte_epost => :parent_email,
      :foresatte_mobil => :billing_phone_mobile,
      :foresatte_nr_2 => :parent_2_name,
      :foresatte_nr_2_mobil => :parent_2_mobile,
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
    Member.where("(left_on IS NULL OR left_on >= '2009-01-01') AND id NOT IN (SELECT member_id FROM nkf_members WHERE member_id IS NOT NULL)").
        order('first_name, last_name').all
  end

  def self.update_group_prices
    contract_types = NkfMember.all.group_by(&:kontraktstype)
    contract_types.each do |contract_name, members_with_contracts|
      monthly_price = members_with_contracts.map(&:kontraktsbelop).group_by { |x| x }.group_by { |k, v| v.size }.sort.last.last.map(&:first).first
      yearly_price = members_with_contracts.map(&:kont_belop).group_by { |x| x }.group_by { |k, v| v.size }.sort.last.last.map(&:first).first
      Group.where(:contract => contract_name).all.each do |group|
        logger.info "Update contract #{group} #{contract_name} #{monthly_price} #{yearly_price}"
        group.update_attributes! :monthly_price => monthly_price, :yearly_price => yearly_price
      end
    end
  end

  def converted_attributes
    new_attributes = {}
    attributes.each do |k, v|
      if FIELD_MAP.keys.include?(k.to_sym)
        mapped_attribute = FIELD_MAP[k.to_sym]
        if mapped_attribute
          if v =~ /^\s*(\d{2}).(\d{2}).(\d{4})\s*$/
            v = "#$3-#$2-#$1"
          elsif v =~ /Mann|Kvinne/
            v = v == 'Mann'
          elsif v.blank? && mapped_attribute =~ /parent|email|mobile|phone/
            v = nil
          end
          new_attributes[mapped_attribute] = v
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
    transaction do
      u = Member.create_corresponding_user! converted_attributes
      member = create_member!(
          converted_attributes.update :instructor => false, :nkf_fee => true,
              :payment_problem => false, :user => u
      )
      member.nkf_member = self
      member
    end
  end

end
