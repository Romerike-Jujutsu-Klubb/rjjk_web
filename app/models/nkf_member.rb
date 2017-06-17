# frozen_string_literal: true

class NkfMember < ApplicationRecord
  FIELD_MAP = {
      adresse_1: { map_to: nil },
      adresse_2: { map_to: :address },
      adresse_3: { map_to: nil },
      antall_etiketter_1: { map_to: nil },
      betalt_t_o_m__dato: { map_to: nil },
      created_at: { map_to: nil },
      epost: { map_to: :email, form_field: :frm_48_v10 },
      epost_faktura: { map_to: :billing_email },
      etternavn: { map_to: :last_name },
      fodselsdato: { map_to: :birthdate },
      foresatte: { map_to: :parent_name },
      foresatte_epost: { map_to: :parent_email },
      foresatte_mobil: { map_to: :billing_phone_mobile },
      foresatte_nr_2: { map_to: :parent_2_name },
      foresatte_nr_2_mobil: { map_to: :parent_2_mobile },
      fornavn: { map_to: :first_name },
      gren_stilart_avd_parti___gren_stilart_avd_parti: { map_to: nil },
      hovedmedlem_id: { map_to: nil },
      hovedmedlem_navn: { map_to: nil },
      id: { map_to: nil },
      innmeldtarsak: { map_to: nil },
      innmeldtdato: { map_to: :joined_on },
      kjonn: { map_to: :male },
      klubb: { map_to: nil },
      klubb_id: { map_to: nil },
      konkurranseomrade_id: { map_to: nil },
      konkurranseomrade_navn: { map_to: nil },
      kont_belop: { map_to: nil },
      kont_sats: { map_to: nil },
      kontraktsbelop: { map_to: nil },
      kontraktstype: { map_to: nil },
      medlemskategori: { map_to: nil },
      medlemskategori_navn: { map_to: nil },
      medlemsnummer: { map_to: nil },
      medlemsstatus: { map_to: nil },
      member_id: { map_to: nil },
      mobil: { map_to: :phone_mobile },
      postnr: { map_to: :postal_code },
      rabatt: { map_to: nil },
      sist_betalt_dato: { map_to: nil },
      sted: { map_to: nil },
      telefon: { map_to: :phone_home },
      telefon_arbeid: { map_to: :phone_work },
      updated_at: { map_to: nil },
      utmeldtarsak: { map_to: nil },
      utmeldtdato: { map_to: :left_on },
      ventekid: { map_to: nil },
      yrke: { map_to: nil },
  }.freeze

  belongs_to :member

  validates :kjonn, presence: true
  validates :member_id, uniqueness: { allow_nil: true }

  def self.find_free_members
    Member
        .where("(left_on IS NULL OR left_on >= '2009-01-01')")
        .where('id NOT IN (SELECT member_id FROM nkf_members WHERE member_id IS NOT NULL)')
        .order('first_name, last_name').to_a
  end

  def self.update_group_prices
    contract_types = NkfMember.all.group_by(&:kontraktstype)
    contract_types.each do |contract_name, members_with_contracts|
      monthly_price = members_with_contracts.map(&:kontraktsbelop)
          .group_by { |x| x }.group_by { |_k, v| v.size }.sort.last.last
          .map(&:first).first
      yearly_price = members_with_contracts.map(&:kont_belop).group_by { |x| x }
          .group_by { |_k, v| v.size }.sort.last.last.map(&:first).first
      Group.where(contract: contract_name).to_a.each do |group|
        logger.info "Update contract #{group} #{contract_name} #{monthly_price} #{yearly_price}"
        group.update! monthly_price: monthly_price, yearly_price: yearly_price
      end
    end
  end

  def converted_attributes
    new_attributes = {}
    attributes.each do |k, v|
      raise "Unknown attribute: #{k}" unless FIELD_MAP.keys.include?(k.to_sym)
      mapped_attribute = FIELD_MAP[k.to_sym][:map_to]
      next unless mapped_attribute
      if v =~ /^\s*(\d{2}).(\d{2}).(\d{4})\s*$/
        v = "#{$3}-#{$2}-#{$1}"
      elsif v =~ /Mann|Kvinne/
        v = v == 'Mann'
      elsif v.blank? && mapped_attribute =~ /parent|email|mobile|phone/
        v = nil
      end
      new_attributes[mapped_attribute] = v
    end
    new_attributes
  end

  def create_corresponding_member!
    transaction do
      u = Member.create_corresponding_user! converted_attributes
      create_member!(converted_attributes.update(instructor: false, nkf_fee: true,
                                                 payment_problem: false, user: u))
    end
  end

  def group_names
    gren_stilart_avd_parti___gren_stilart_avd_parti.split(/ - /).map { |n| n.split('/')[3] }
  end
end
