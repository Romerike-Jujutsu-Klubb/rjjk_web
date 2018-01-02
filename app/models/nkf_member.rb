# frozen_string_literal: true

class NkfMember < ApplicationRecord
  FIELD_MAP = {
    adresse_1: {},
    adresse_2: { map_to: :address, form_field: :frm_48_v05 },
    adresse_3: {},
    antall_etiketter_1: {},
    betalt_t_o_m__dato: {},
    created_at: {},
    epost: { map_to: :email, form_field: :frm_48_v10 },
    epost_faktura: { map_to: :billing_email, form_field: :frm_48_v22 },
    etternavn: { map_to: :last_name, form_field: :frm_48_v04 },
    fodselsdato: { map_to: :birthdate, form_field: :frm_48_v08 },
    foresatte: { map_to: :parent_name, form_field: :frm_48_v23 },
    foresatte_epost: { map_to: :parent_email, form_field: :frm_48_v73 },
      # FIXME(uwe): Remove import
    foresatte_mobil: { map_to: :phone_parent, form_field: :frm_48_v74, import: true },
    foresatte_nr_2: { map_to: :parent_2_name, form_field: :frm_48_v72 },
    foresatte_nr_2_mobil: { map_to: :parent_2_mobile, form_field: :frm_48_v75 },
    fornavn: { map_to: :first_name, form_field: :frm_48_v03 },
    gren_stilart_avd_parti___gren_stilart_avd_parti: {},
    hovedmedlem_id: {},
    hovedmedlem_navn: {},
    id: {},
    innmeldtarsak: {},
    innmeldtdato: { map_to: :joined_on, form_field: :frm_48_v45 },
    kjonn: { map_to: :male }, # form_field: :frm_48_v112 values: true: 'M' or false: 'K'
    klubb: {},
    klubb_id: {},
    konkurranseomrade_id: {},
    konkurranseomrade_navn: {},
    kont_belop: {},
    kont_sats: {},
    kontraktsbelop: {},
    kontraktstype: {},
    medlemskategori: {},
    medlemskategori_navn: {},
    medlemsnummer: {},
    medlemsstatus: {},
    member_id: {},
    mobil: { map_to: :phone_mobile, form_field: :frm_48_v20 },
    postnr: { map_to: :postal_code, form_field: :frm_48_v07 },
    rabatt: {},
    sist_betalt_dato: {},
    sted: {},
    telefon: { map_to: :phone_home, form_field: :frm_48_v19 },
    telefon_arbeid: { map_to: :phone_work, form_field: :frm_48_v21 },
    updated_at: {},
    utmeldtarsak: {},
    utmeldtdato: { map_to: :left_on, form_field: :frm_48_v46 },
    ventekid: {},
    yrke: {},
  }.freeze

  belongs_to :member, required: false

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
      mapped_attribute, mapped_value = self.class.rjjk_attribute(k, v)
      new_attributes[mapped_attribute] = mapped_value if mapped_attribute
    end
    new_attributes
  end

  def self.rjjk_attribute(k, v)
    raise "Unknown attribute: #{k}" unless FIELD_MAP.keys.include?(k.to_sym)
    mapped_attribute = FIELD_MAP[k.to_sym][:map_to]
    if mapped_attribute
      mapped_value =
          if /^\s*(?<day>\d{2})\.(?<month>\d{2})\.(?<year>\d{4})\s*$/ =~ v
            Date.new(year.to_i, month.to_i, day.to_i)
          elsif v =~ /Mann|Kvinne/
            v == 'Mann'
          elsif v.blank? && mapped_attribute =~ /parent|email|mobile|phone/
            nil
          else
            v
          end
    end
    [mapped_attribute, mapped_value]
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
