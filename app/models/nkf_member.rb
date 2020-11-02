# frozen_string_literal: true

class NkfMember < ApplicationRecord
  include NkfAttributeConversion

  has_paper_trail

  belongs_to :member, optional: true
  has_one :user, through: :member

  validates :kjonn, presence: true
  validates :member_id, uniqueness: { allow_nil: true }

  def self.find_free_members
    Member
        .where("(left_on IS NULL OR left_on >= '2009-01-01')")
        .where('id NOT IN (SELECT member_id FROM nkf_members WHERE member_id IS NOT NULL)')
        .order(:id).to_a
  end

  def self.update_group_prices
    contract_types = NkfMember.all.group_by(&:kontraktstype)
    contract_types.each do |contract_name, members_with_contracts|
      monthly_fee = members_with_contracts.map(&:kontraktsbelop)
          .group_by { |x| x }.group_by { |_k, v| v.size }.max.last
          .map(&:first).first
      yearly_fee = members_with_contracts.map(&:kont_belop).group_by { |x| x }
          .group_by { |_k, v| v.size }.max.last.map(&:first).first
      Group.where(contract: contract_name).to_a.each do |group|
        logger.info "Update contract #{group} #{contract_name} #{monthly_fee} #{yearly_fee}"
        group.update! monthly_fee: monthly_fee, yearly_fee: yearly_fee
      end
    end
  end

  MEMBER_DEFAULT_ATTRIBUTES = { instructor: false, nkf_fee: true, payment_problem: false }.freeze

  def create_corresponding_member!
    transaction do
      attributes = converted_attributes(include_blank: false)
      membership_attributes = attributes[:membership]
      logger.error "membership_attributes: #{membership_attributes.inspect}"
      user = create_corresponding_user!(attributes)

      member_attributes_with_defaults = membership_attributes.update(MEMBER_DEFAULT_ATTRIBUTES)

      logger.error "membership users: #{{ user: user }}"
      member = build_member(user: user)

      logger.error "member_attributes_with_defaults: #{member_attributes_with_defaults}"
      member.update! member_attributes_with_defaults
      member.update! user: user # FIXME(uwe):  Why is this needed?  Remove!

      member_groups = if (nkf_group_names = group_names).any?
                        logger.info "Adding groups from NKF: #{nkf_group_names}"
                        Group.where(name: nkf_group_names)
                      else
                        logger.info "Adding groups by age: #{user.age}"
                        Group.active.where(from_age: 0..user.age, to_age: user.age..100)
                      end
      user.groups = member_groups.to_a
      user.save!

      member
    end
  end

  def group_names
    gren_stilart_avd_parti___gren_stilart_avd_parti.split(/ - /).map { |n| n.split('/')[3] }
  end

  def to_s
    "#{fornavn} #{etternavn}"
  end
end
