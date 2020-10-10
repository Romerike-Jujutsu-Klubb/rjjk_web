# frozen_string_literal: true

class SignupController < ApplicationController
  # FIXME(uwe): Bruke egen layout uten distraherende elementer?

  layout PUBLIC_LAYOUT

  before_action do
    @layout_menu_title = 'Innmelding'
    @layout_no_footer = true
  end

  def name_and_birthdate
    @user = User.new
  end

  def guardians
    @user = User.new(params[:user])
    @user.guardian_1 ||= User.new
    render :guardians
  end

  # Posted after name_and_birthdate and guardians
  def contact_info
    @user = User.new(params[:user])
    return if @user.age >= 18 || @user.guardian_1&.contact_info?

    guardians
  end

  def groups
    @user = User.new(params[:user])
    existing_email_user = User.find_by(email: @user.contact_email) if @user.email.present?
    existing_email_user ||= User.find_by(phone: @user.phone) if @user.phone.present?
    if existing_email_user
      flash.notice =
          "Vi har allerede registrert #{existing_email_user.name} (#{existing_email_user.email}) fra før."
      if existing_email_user.member
        flash.alert = "#{existing_email_user.name} er allerede medlem!"
        redirect_to login_path
        return
      end
      @user = existing_email_user
      @user.attributes = params[:user]
    end
    @groups = Group.active.to_a
    return unless @user.groups.empty?

    @groups.each do |g|
      @user.group_ids << g.id if (g.from_age..g.to_age).cover? @user.age
    end
  end

  def complete
    Signup.transaction do
      group_ids = params[:user].delete(:group_ids)
      if (existing_user_id = params[:user][:id].presence)
        user = User.find(existing_user_id)
        user.update! params[:user]
      else
        user = User.create! params[:user]
      end
      user.group_ids = group_ids
      user.save!
      agent = NkfAgent.new(:signup)
      trial_form_page = agent.new_trial_form
      trial_form = trial_form_page.form('ks_bli_medlem')
      trial_form.frm_29_v03 = user.first_name
      trial_form.frm_29_v04 = user.last_name
      trial_form.frm_29_v07 = user.postal_code
      trial_form.frm_29_v08 = user.birthdate.strftime('%d.%m.%Y')
      trial_form.radiobutton_with(name: 'frm_29_v11', value: user.male ? 'M' : 'K').check
      trial_form.frm_29_v13 = user.height || 10
      trial_form.frm_29_v10 = user.contact_email
      trial_form['frm_29_v16'] = 524 # Jujutsu (Ingen stilartstilknytning)
      trial_form['p_ks_bli_medlem_action'] = 'OK'

      reg_response = agent.submit(trial_form)
      logger.info reg_response.inspect
      logger.info Nokogiri::XML(reg_response.body.force_encoding('ISO-8859-1').encode('UTF-8'), &:noblanks)
          .to_s
      # raise unless reg_response.statu
      @signup = Signup.create!(user: user)

      NkfImportTrialMembersJob.perform_later
    end
  end
end
