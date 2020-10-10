# frozen_string_literal: true

class SignupsController < ApplicationController
  before_action :admin_required
  before_action :set_signup, only: %i[show edit update destroy]

  def index
    @signups = Signup.order(created_at: :desc)
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
    @users = [@signup.user]
    @nkf_member_trials = [@signup.nkf_member_trial]
    render :edit
  end

  def create
    @signup = Signup.new(signup_params)
    Signup.transaction do
      if @signup.user_id_before_type_cast == 'new_user' && @signup.nkf_member_trial.present?
        @signup.user = User.create! @signup.nkf_member_trial.user_attributes
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
    # nkf_agent = NkfAgent.new(:complete_signup)
    # front_page = nkf_agent.login # returns front_page
    # trial_index_page = nkf_agent.trial_index
  end

  def terminate
    Signup.transaction do
      @signup = Signup.find(params[:id])
      if (trial = @signup.nkf_member_trial)
        nkf_agent = NkfAgent.new(:complete_signup)
        nkf_agent.login
        trial_index_page = nkf_agent.trial_index
        form = trial_index_page.form('ks_godkjenn_medlem')
        form['p_ks_godkjenn_medlem_action'] = 'DELETE'
        form['frm_28_v04'] = trial.tid
        response_page = nkf_agent.submit(form)
        logger.info response_page.inspect
        body = response_page.body.force_encoding('ISO-8859-1').encode('UTF-8')
        logger.info Nokogiri::XML(body, &:noblanks).to_s
        NkfImportTrialMembersJob.perform_later
      end
      @signup.destroy!
    end
  end

  def destroy
    @signup.destroy
    redirect_to signups_url, notice: 'Signup was successfully destroyed.'
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
