# frozen_string_literal: true

class SignupsController < ApplicationController
  before_action :admin_required
  before_action :set_signup, only: %i[show edit update destroy complete terminate]

  def index
    @signups = Signup.includes(:nkf_member_trial, :user).references(:nkf_member_trials)
        .order(:reg_dato, :created_at).to_a
  end

  def show; end

  def new
    @signup ||= Signup.new(params[:signup])
    @users ||= User.with_deleted.includes(:member, :signups)
        .where(members: { id: nil }, signups: { id: nil })
        .order(:first_name, :last_name).to_a
    @nkf_member_trials ||=
        NkfMemberTrial.includes(:signup).where(signups: { id: nil }).order(:fornavn, :etternavn).to_a
    if @signup.nkf_member_trial
      @q = [@signup.nkf_member_trial.attributes.fetch_values('fornavn', 'etternavn', 'epost', 'mobil')]
          .join(' ')
      @candidate_users = User.search(@q).to_a.reject(&:member)
      @deleted_users = User.only_deleted.search(@q).to_a
    end
    render :new
  end

  def edit
    @users ||= [@signup.user].compact + User.with_deleted.includes(:member, :signups)
        .where(members: { id: nil }, signups: { id: nil })
        .order(:first_name, :last_name).to_a
    @nkf_member_trials = [@signup.nkf_member_trial].compact +
        NkfMemberTrial.includes(:signup).where(signups: { id: nil }).order(:fornavn, :etternavn).to_a
    render :edit
  end

  def create
    @signup = Signup.new(signup_params)
    Signup.transaction do
      if @signup.user_id_before_type_cast == 'new_user' && @signup.nkf_member_trial.present?
        @signup.user = User.create! @signup.nkf_member_trial.converted_attributes(include_blank: false)
      end
      @signup.user&.restore!
      if @signup.save
        redirect_to signups_path, notice: 'Signup was successfully created.'
      else
        new
      end
    end
  end

  def update
    if @signup.update(signup_params)
      redirect_to signups_path, notice: 'Signup was successfully updated.'
    else
      edit
    end
  end

  def complete
    nkf_agent = NkfAgent.new(:complete_signup)
    nkf_agent.login # returns front_page
    trial_index_page = nkf_agent.trial_index

    if @signup.nkf_member_trial
      trial_page = nkf_agent.trial_page(@signup.nkf_member_trial.tid)
      trial_form = trial_page.form('ks_godkjenn_medlem')
      trial_form['frm_28_v06'] = 'G'
      trial_form.field_with(name: 'frm_28_v66').checked = true
      trial_form['frm_28_v60'] = trial_form.field_with(name: 'frm_28_v36').options[1].value
      trial_form['p_ks_godkjenn_medlem_action'] = 'OK'
      approval_page = trial_form.submit

      logger.info approval_page.inspect
      approval_body = approval_page.body.force_encoding('ISO-8859-1').encode('UTF-8')
      logger.info Nokogiri::XML(approval_body, &:noblanks).to_s

      if (m = NkfForm::MEMBER_ERROR_PATTERN.match(approval_body))
        raise <<~MESSAGE
          Error approving NKF trial member:
          #{m[:message].encode(Encoding::UTF_8, form.encoding)}
          #{form.fields.map { |f| "#{f.name}: #{f.value.inspect}" }.join("\n")}
        MESSAGE
      end
    else
      form = trial_index_page.form('ks_godkjenn_medlem')

      form['p_ks_godkjenn_medlem_action'].value = 'UPDATE'
      form['frm_28_v04'] = ''
      new_member_page = nkf_agent.submit(form)

      logger.info new_member_page.inspect
      approval_body = new_member_page.body.force_encoding('ISO-8859-1').encode('UTF-8')
      logger.info Nokogiri::XML(approval_body, &:noblanks).to_s

      member_form = new_member_page.form('')
      member_form['frm_28_v04'] = ''

      # FIXME(uwe): Actually create a new member!!!

    end
    NkfSynchronizationJob.perform_later
    redirect_to signups_path, notice: 'Medlemskapet er opprettet.'
  end

  def terminate
    Signup.transaction do
      if (trial = @signup.nkf_member_trial)
        nkf_agent = NkfAgent.new(:complete_signup)
        nkf_agent.login
        trial_index_page = nkf_agent.trial_index
        form = trial_index_page.form('ks_godkjenn_medlem')
        form['p_ks_godkjenn_medlem_action'] = 'DELETE'
        form['frm_28_v04'] = trial.tid
        nkf_agent.submit(form)
        trial.destroy!
        NkfImportTrialMembersJob.perform_later
      end
      @signup.destroy!
    end
    redirect_to signups_path, notice: 'Prøvemedlemskapet er avsluttet.'
  end

  def destroy
    @signup.destroy
    redirect_to signups_url, notice: 'Signup was successfully destroyed.'
  end

  def export
    NkfExportTrialMembersJob.perform_later
    NkfImportTrialMembersJob.perform_later
    redirect_to signups_path, notice: 'Started NKF export.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_signup
    @signup ||= Signup.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def signup_params
    params.require(:signup).permit(:user_id, :nkf_member_trial_id)
  end
end
