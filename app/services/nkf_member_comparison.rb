# frozen_string_literal: true

class NkfMemberComparison
  attr_reader :errors, :member_changes, :members, :new_members, :orphan_members,
      :orphan_nkf_members, :outgoing_changes

  def initialize
    fetch
  end

  def any?
    [@new_members, @member_changes, @errors].any?(&:present?)
  end

  private def fetch
    @orphan_nkf_members = NkfMember.where(member_id: nil).order(:fornavn, :etternavn, :id).to_a
    @orphan_members = NkfMember.find_free_members
    @members = []
    nkf_members = NkfMember.where('member_id IS NOT NULL').order(:fornavn, :etternavn, :id).to_a
    nkf_members.each do |nkfm|
      member = nkfm.member
      relations = assign_nkf_attributes(member)
      @members << member if relations.any?(&:changed?)
    end
  end

  def sync
    agent, front_page = setup_sync
    create_new_members
    sync_members(agent, front_page)
  end

  private def sync_members(agent, front_page)
    @member_changes = @members.map do |m|
      sync_member_with_agent(agent, front_page, m)
    end.compact
  end

  def sync_member(member)
    agent, front_page = setup_sync
    assign_nkf_attributes(member)
    sync_member_with_agent(agent, front_page, member)
  end

  private

  def assign_nkf_attributes(member)
    converted_attributes = member.nkf_member.converted_attributes
    relations = []
    converted_attributes.each do |target, nkf_values|
      relation =
          if target == :membership
            member
          elsif target == :member
            member.user
          elsif target == :billing
            if member.billing_user
              member.billing_user
            elsif nkf_values.any? { |_k, v| v.present? }
              if nkf_values[:email] && (existing_email_user = User.find_by(email: nkf_values[:email]))
                logger.info "Use existing billing user: #{existing_email_user}"
                member.billing_user = existing_email_user
                existing_email_user
              else
                logger.info "Create new billing user: #{nkf_values}"
                member.build_billing_user
              end
            end
          else
            parent_idx = target.to_s[/\d+$/].to_i
            (member.user.guardianships.find { |g| g.index == parent_idx } ||
                ((nkf_values.any? { |_k, v| v.present? } || nil) &&
                    member.user.guardianships.build(index: parent_idx, guardian_user: User.new))
            )&.guardian_user
          end
      next unless relation
      nkf_values.each do |attribute, nkf_value|
        rjjk_value = relation.send(:"#{attribute}")
        next unless nkf_value != rjjk_value
        logger.info "Member (#{'%4d' % member.id}) #{target} #{relation.class} " \
              "(#{'%4s' % relation.id.inspect}): #{attribute}: " \
              "#{rjjk_value.inspect} => #{nkf_value.inspect}"
        relation.send(:"#{attribute}=", nkf_value)
      end
      relations |= [relation]
    end
    relations
  end

  def create_new_members
    @new_members = @orphan_nkf_members.map do |nkf_member|
      begin
        logger.info "Create member from NKF: #{nkf_member.inspect}"
        nkf_member.create_corresponding_member!
      rescue => e
        logger.error e
        logger.error e.backtrace.join("\n")
        @errors << ['New member', e, nkf_member]
        nil
      end
    end.compact
  end

  private def sync_attribute(attr_sym, form, new_value, old_value, outgoing_changes, record)
    return if old_value.blank? && new_value.blank?
    _nkf_column, nkf_mapping = NkfMember::FIELD_MAP.find do |_k, v|
      [*v[:map_from]].include?(attr_sym) || v[:map_to] == attr_sym
    end
    return if nkf_mapping && nkf_mapping[:import]
    if (nkf_field = nkf_mapping&.fetch(:form_field, nil))
      form_value = old_value.is_a?(Date) ? old_value.strftime('%d.%m.%Y') : old_value # rubocop: disable Style/FormatStringToken
      logger.info "set form value #{nkf_field.inspect} = #{form_value.inspect}"
      form[nkf_field.to_s] = form_value
      outgoing_changes[attr_sym] = { new_value => old_value }
    elsif attr_sym == { membership: :billing_user_id }
      record.billing_user.attributes.each do |billing_attr, new_billing_value|
        next if new_billing_value.nil?
        billing_attr_sym = { billing: billing_attr.to_sym }
        sync_attribute(billing_attr_sym, form, new_billing_value, nil, outgoing_changes, record)
      end
    else
      @errors << ['Unhandled change', attr_sym, record]
    end
  end

  private def setup_sync
    @errors = []
    @outgoing_changes = []
    agent = NkfAgent.new
    front_page = agent.login
    [agent, front_page]
  end

  private def sync_member_with_agent(agent, front_page, m)
    logger.info "Synching member: #{m.nkf_member.medlemsnummer} #{m.inspect}"
    logger.info "m.changes: #{m.changes.pretty_inspect}"
    if m.user.invalid?
      if m.user.errors[:phone]
        if m.user.phone.present? && (conflicting_phone_user = User.find_by(phone: m.user.phone))
          if conflicting_phone_user.member.nil? || conflicting_phone_user.member.left_on
            logger.info "Move phone #{m.user.phone} from user #{conflicting_phone_user.id} "\
                "#{conflicting_phone_user.name} to #{m.user.inspect}"
            conflicting_phone_user.update! phone: nil
          else
            logger.info "Reset user phone #{m.user.phone} since it is used by "\
                "#{conflicting_phone_user.inspect}"
            m.user.phone = nil
          end
        end
      end
    end
    if m.billing_user
      logger.info "m.billing_user: #{m.billing_user.changes.pretty_inspect}"
      if !m.billing_user.persisted? && (related_user_email = m.billing_user.email)
        if (existing_billing_user = User.find_by(email: related_user_email))
          m.billing_user = existing_billing_user
        end
      end
    end
    search_form = front_page.form('ks_reg_medladm') do |search|
      search.p_ks_reg_medladm_action = 'SEARCH'
      search['frm_27_v29'] = 0
      search['frm_27_v40'] = m.nkf_member.medlemsnummer
    end
    search_result = search_form.submit
    edit_link = search_result.css('tr.trList td.tdListData1')[9]
    token = edit_link.attr('onclick')[14..-3]
    member_page = agent.get("page/portal/ks_utv/ks_medlprofil?p_cr_par=#{token}")
    outgoing_changes_for_member = {}
    member_form = member_page.form('ks_medlprofil') do |form|
      m.changes.each do |attr, (old_value, new_value)|
        sync_attribute({ membership: attr.to_sym }, form, new_value, old_value,
            outgoing_changes_for_member, m)
      end
      m.related_users.each do |relationship, u|
        u.changes.each do |attr, (old_value, new_value)|
          attr = { relationship => attr.to_sym }
          sync_attribute(attr, form, new_value, old_value, outgoing_changes_for_member, u)
        end
      end
      @outgoing_changes << [m, outgoing_changes_for_member] if outgoing_changes_for_member.any?
    end
    logger.info "outgoing_changes: #{outgoing_changes_for_member}"
    if Rails.env.production?
      if outgoing_changes_for_member.any?
        # m.restore_attributes(outgoing_changes_for_member.keys)
        logger.info 'Submitting form to NKF'
        logger.info member_form.pretty_inspect
        member_form['p_ks_medlprofil_action'] = 'OK'
        member_form.submit
      end
      return
    end
    changes = m.changes
    m.related_users.each do |relationship, u|
      if u.changed?
        changes[relationship] = u.changes
      elsif relationship == :billing && m.billing_user_id_changed?
        # changes.delete('billing_user_id')
        changes[relationship] = Hash[u.attributes.except('created_at', 'updated_at')
            .reject { |_k, v| v.nil? }.map { |k, v| [k, [nil, v]] }]
      end
    end
    unless changes.empty?
      m.save!
      [m, changes]
    end
  rescue => e
    logger.error "Exception saving member changes for #{m.attributes.inspect}"
    logger.error e.message
    logger.error e.backtrace.join("\n")
    @errors << ['Changes', e, m]
    nil
  end
end
