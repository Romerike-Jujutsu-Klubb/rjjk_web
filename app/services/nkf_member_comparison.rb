# frozen_string_literal: true

class NkfMemberComparison
  MEMBER_ERROR_PATTERN =
      %r{<div class=divError id="div_48_v04">\s*<ul class="ulError">(?<message>.*?)</ul>\s*</div>}.freeze

  attr_reader :errors, :member_changes, :members, :new_members, :orphan_members,
      :orphan_nkf_members, :outgoing_changes

  def initialize(member_id = nil)
    load_changes(member_id)
  end

  def any?
    [@new_members, @member_changes, @errors].any?(&:present?)
  end

  def sync
    agent, front_page = setup_sync
    create_new_members
    sync_members(agent, front_page)
    self
  end

  private

  def load_changes(member_id)
    @orphan_nkf_members = NkfMember.where(member_id: nil).order(:fornavn, :etternavn, :id).to_a
    @orphan_members = NkfMember.find_free_members
    @members = []
    base_query = NkfMember.order(:fornavn, :etternavn, :id)
    query = member_id ? base_query.where(member_id: member_id) : base_query.where.not(member_id: nil)
    query.each do |nkfm|
      member = nkfm.member
      relations = assign_nkf_attributes(member)
      @members << member if relations.any?(&:changed?)
    end
  end

  def sync_members(agent, front_page)
    @member_changes = @members.map do |m|
      sync_member_with_agent(agent, front_page, m)
    end.compact
  end

  def assign_nkf_attributes(member)
    converted_attributes = member.nkf_member.converted_attributes
    relations = []
    converted_attributes.each do |target, nkf_values|
      relation =
          if target == :membership
            member
          elsif target == :user
            member.user
          elsif target == :billing
            if member.user.billing_user
              member.user.billing_user
            elsif nkf_values.any? { |_k, v| v.present? }
              if nkf_values[:email] && (existing_email_user = User.find_by(email: nkf_values[:email]))
                logger.info "Use existing billing user: #{existing_email_user}"
                member.user.billing_user = existing_email_user
                existing_email_user
              else
                logger.info "Create new billing user: #{nkf_values}"
                member.user.build_billing_user
              end
            end
          elsif target == :guardian_1
            member.user.guardian_1 ||
                ((nkf_values.any? { |_k, v| v.present? } || nil) && member.user.build_guardian_1)
          elsif target == :guardian_2
            member.user.guardian_2 ||
                ((nkf_values.any? { |_k, v| v.present? } || nil) && member.user.build_guardian_2)
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
    created_members = @orphan_nkf_members.map do |nkf_member|
      logger.info "Create member from NKF: #{nkf_member.inspect}"
      nkf_member.create_corresponding_member!
    rescue => e
      logger.error e
      logger.error e.backtrace.join("\n")
      @errors << ['New member', e, nkf_member]
      nil
    end
    @new_members = created_members.compact
  end

  def sync_attribute(membership, attr_sym, form, new_value, old_value, outgoing_changes, record)
    return if old_value.blank? && new_value.blank?

    _nkf_column, nkf_mapping = NkfMember::FIELD_MAP.find do |_k, v|
      [*v[:map_from]].include?(attr_sym) || v[:map_to] == attr_sym
    end
    return if nkf_mapping && nkf_mapping[:import]

    if (nkf_field = nkf_mapping&.fetch(:form_field, nil))
      if nkf_mapping[:map_to] != attr_sym
        translation = nkf_mapping[:map_to].to_a[0]
        export_value = membership.send(translation[0]).send("#{translation[1]}_was")
      else
        export_value = old_value
      end
      form_value = export_value.is_a?(Date) ? export_value.strftime('%d.%m.%Y') : export_value
      logger.info "set form value #{nkf_field.inspect} = #{form_value.inspect}"
      form[nkf_field.to_s] = form_value
      outgoing_changes[attr_sym] = { new_value => export_value }
    elsif attr_sym == { user: :billing_user_id }
      record.billing_user.attributes.each do |billing_attr, new_billing_value|
        next if new_billing_value.nil?

        billing_attr_sym = { billing: billing_attr.to_sym }
        sync_attribute(membership, billing_attr_sym, form, new_billing_value, nil, outgoing_changes,
            record)
      end
    elsif [{ user: :latitude }, { user: :longitude }].include?(attr_sym)
    else
      @errors << ['Unhandled change', attr_sym, record]
    end
  end

  def setup_sync
    @errors = []
    @outgoing_changes = []
    agent = NkfAgent.new
    front_page = agent.login
    [agent, front_page]
  end

  def sync_member_with_agent(agent, front_page, m)
    logger.info "Synching member: #{m.user.name} #{m.nkf_member.medlemsnummer} #{m.inspect}"
    logger.info "m.changes: #{m.changes.pretty_inspect}"
    verify_user(m)
    verify_billing_user(m)
    submit_changes_to_nkf(agent, front_page, m)
    return if Rails.env.production?

    save_incoming_changes(m)
  rescue => e
    logger.error "Exception saving member changes for #{m.attributes.inspect}"
    logger.error e.message
    logger.error e.backtrace.join("\n")
    @errors << ['Changes', e, m]
    nil
  end

  def gather_changes(m)
    changes = m.changes
    m.related_users.each do |relationship, u|
      if u.changed?
        changes[relationship] = u.changes
      elsif relationship == :billing && m.user.billing_user_id_changed?
        # changes.delete('billing_user_id')
        changes[relationship] = Hash[u.attributes.except('created_at', 'updated_at')
            .reject { |_k, v| v.nil? }.map { |k, v| [k, [nil, v]] }]
      end
    end
    changes
  end

  def submit_changes_to_nkf(agent, front_page, m)
    member_form, outgoing_changes_for_member = find_outgoing_changes(agent, front_page, m)
    return unless Rails.env.production? && outgoing_changes_for_member.any?

    # m.restore_attributes(outgoing_changes_for_member.keys)
    logger.info 'Submitting form to NKF'
    logger.debug member_form.pretty_inspect
    member_form['p_ks_medlprofil_action'] = 'OK'
    change_response_page = member_form.submit
    logger.info do
      "change_response_page: code: #{change_response_page.code.inspect}\n#{change_response_page.body}"
    end
    if (m = MEMBER_ERROR_PATTERN.match(change_response_page.body))
      ms = m[:message]
      message = "Error updating NKF member form: #{ms.encode(Enccoding::UTF_8)}"
      logger.error "message.encoding: #{message.encoding}"
      raise message
    end

    change_response_page
  end

  def save_incoming_changes(m)
    changes = gather_changes(m)
    return if changes.empty?

    m.save!
    [m, changes]
  end

  def find_outgoing_changes(agent, front_page, membership)
    search_form = front_page.form('ks_reg_medladm') do |search|
      search.p_ks_reg_medladm_action = 'SEARCH'
      search['frm_27_v29'] = 0
      search['frm_27_v40'] = membership.nkf_member.medlemsnummer
    end
    search_result = search_form.submit
    edit_link = search_result.css('tr.trList td.tdListData1')[9]
    token = edit_link.attr('onclick')[14..-3]
    member_page = agent.get("page/portal/ks_utv/ks_medlprofil?p_cr_par=#{token}")
    outgoing_changes_for_member = {}
    member_form = member_page.form('ks_medlprofil') do |form|
      membership.changes.each do |attr, (old_value, new_value)|
        sync_attribute(membership, { membership: attr.to_sym }, form, new_value, old_value,
            outgoing_changes_for_member, membership)
      end
      membership.related_users.each do |relationship, u|
        u.changes.each do |attr, (old_value, new_value)|
          attr = { relationship => attr.to_sym }
          sync_attribute(membership, attr, form, new_value, old_value, outgoing_changes_for_member, u)
        end
      end
      @outgoing_changes << [membership, outgoing_changes_for_member] if outgoing_changes_for_member.any?
    end
    logger.info "outgoing_changes: #{outgoing_changes_for_member}"
    [member_form, outgoing_changes_for_member]
  end

  def verify_user(m)
    return unless m.user.invalid?
    return unless m.user.errors[:phone]

    if m.user.phone.present? &&
          (conflicting_phone_user = User.where.not(id: m.user_id).find_by(phone: m.user.phone))
      if conflicting_phone_user.member.nil? || conflicting_phone_user.member.left_on
        logger.info "Move phone #{m.user.phone} from user #{conflicting_phone_user.id} "\
            "#{conflicting_phone_user.name} to #{m.user.inspect}"
        conflicting_phone_user.phone = nil
        if conflicting_phone_user.contact_info?
          conflicting_phone_user.save!
        else
          logger.info "Delete user #{conflicting_phone_user.name} #{conflicting_phone_user.id} " \
              'since it has no contact information.'
          conflicting_phone_user.contactees.each { |u| u.update! contact_user_id: m.user.id }
          conflicting_phone_user.payees.each { |u| u.update! billing_user_id: m.user.id }
          conflicting_phone_user.primary_wards.each { |u| u.update! guardian_1_id: m.user.id }
          conflicting_phone_user.secondary_wards.each { |u| u.update! guardian_2_id: m.user.id }
          conflicting_phone_user.destroy!
        end
      else
        logger.info "Reset user phone #{m.user.phone} since it is used by "\
            "#{conflicting_phone_user.inspect}"
        m.user.phone = nil
      end
    end
  end

  def verify_billing_user(m)
    return unless m.user.billing_user

    logger.info "m.user.billing_user: #{m.user.billing_user.changes.pretty_inspect}"
    return if m.user.billing_user.persisted? || (related_user_email = m.user.billing_user.email).blank?
    return unless (existing_billing_user = User.find_by(email: related_user_email))

    # FIXME(uwe): Should this ever happen?
    m.user.billing_user = existing_billing_user
  end
end
