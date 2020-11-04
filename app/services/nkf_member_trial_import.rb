# frozen_string_literal: true

class NkfMemberTrialImport
  include ParallelRunner
  include MonitorMixin
  include NkfForm

  attr_reader :error_records, :exception, :trial_changes

  # @param nkf_member_ids [Integer|Array<Integer>] only import the given NKF member id(s)
  def initialize(nkf_agent = nil)
    super() # needed for MonitorMixin
    @trial_changes = []
    @error_records = []
    @cookies = []

    if nkf_agent
      nkf_agent.main_page
    else
      nkf_agent = NkfAgent.new(:trial_import)
      nkf_agent.login
    end
    get_member_trial_rows(nkf_agent)
  rescue => e
    @exception = e
    logger.error e
    logger.error e.backtrace.join("\n")
  end

  def size
    trial_changes&.size.to_i + error_records&.size.to_i
  end

  def any?
    @exception || size.positive?
  end

  private

  def get_member_trial_rows(nkf_agent)
    logger.debug 'get_member_trial_rows'

    trial_ids = []

    # FIXME(uwe): Add pagination when reading NKF member trials
    trial_index_page = nkf_agent.trial_index
    member_trials_body = trial_index_page.body
    new_trial_ids = member_trials_body.scan(/edit_click28\('(.*?)'\)/).map(&:first)
    trial_ids += new_trial_ids

    logger.debug "Found #{trial_ids.size} member trials"

    NkfMemberTrial.where.not(tid: trial_ids).to_a.each do |t|
      logger.info "orphaned_trial: #{t}"
      t.signup&.destroy!
      t.destroy!
      @trial_changes << { record: t, changes: :deleted }
    end

    trial_ids.each do |tid|
      Signup.transaction do
        trial_details_page = nkf_agent.trial_page(tid)
        if (nkf_trial = NkfMemberTrial.find_by(tid: tid))
          if nkf_trial.signup.nil?
            user = User.find_by(email: changes[:epost]) if changes[:epost].present?
            user ||= User.find_by(phone: changes[:mobil]) if changes[:mobil].present?
            user ||= User.create!(nkf_trial.converted_attributes(include_blank: false))
            nkf_trial.create_signup! user: user
          end

          # FIXME(uwe): Change to submitting the form when we are sure it is safe
          # mapped_changes = signup.mapping_attributes
          # changes = submit_form(trial_details_page, 'ks_godkjenn_medlem', mapped_changes, :trial)
          # logger.info "changes: #{changes}"
          # @trial_changes << { record: nkf_trial, changes: changes }
          # EMXIF

          # FIXME(uwe): Remove when we submit the form
          form = trial_details_page.form('ks_godkjenn_medlem')
          nkf_trial.attributes = read_form(form, :trial)
          next unless nkf_trial.changed?

          changes = nkf_trial.changes
          if nkf_trial.save
            @trial_changes << { record: nkf_trial, changes: changes }
          else
            logger.error "ERROR: #{nkf_trial.attributes}"
            logger.error "ERROR: #{nkf_trial.errors.to_a.join(', ')}"
            @error_records << nkf_trial
          end
          # EMXIF
        else
          # New trial
          form = trial_details_page.form('ks_godkjenn_medlem')
          nkf_trial_attributes = read_form(form, :trial)
          nkf_trial = NkfMemberTrial.create!(tid: tid, **nkf_trial_attributes)
          user = User.find_by(email: nkf_trial_attributes[:epost]) if nkf_trial_attributes[:epost].present?
          if nkf_trial_attributes[:mobil].present?
            user ||= User.find_by(phone: nkf_trial_attributes[:mobil])
          end
          user ||=
              nkf_trial.create_corresponding_user!(nkf_trial.converted_attributes(include_blank: false))
          if user.signup
            user.signup.update! nkf_member_trial: nkf_trial
          else
            Signup.create! user: user, nkf_member_trial: nkf_trial
          end
          @trial_changes << { record: nkf_trial, changes: :new }
        end
      end
    end
  end

  def field2column(field_name)
    field_name.tr('ø', 'o').tr('Ø', 'O').tr('å', 'a').tr('Å', 'A').gsub(%r{[ -./]}, '_').downcase
  end
end
