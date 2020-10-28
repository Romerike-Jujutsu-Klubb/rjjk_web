# frozen_string_literal: true

class SignupGuideController < ApplicationController
  include NkfForm

  layout PUBLIC_LAYOUT

  before_action do
    @layout_menu_title = 'Innmelding'
    @layout_no_footer = true
  end

  def basics
    return if load_signup

    return unless request.post?

    if @user.birthdate && (@user.birthdate.year < 100)
      @user.birthdate += (@user.birthdate.year > (Date.current.year % 100) ? 1900 : 2000).years
    end
    @user.signup ||= Signup.new(user: @user)
    store_signup

    return unless @user.valid? || (@user.errors.keys & %i[birthdate first_name last_name male name]).empty?

    redirect_to signup_guide_contact_info_path
  end

  def guardians
    return if load_signup

    @user.guardian_1 ||= User.new
    return unless request.post?

    store_signup
    return redirect_to signup_guide_basics_path if params[:back]
  end

  # Posted after name_and_birthdate and guardians
  def contact_info
    return if load_signup
    return unless request.post?

    store_signup
    return redirect_to signup_guide_basics_path if params[:back]

    existing_mail_user = User.find_by(email: @user.contact_email) if @user.email.present?
    existing_mail_user ||= User.find_by(phone: @user.phone) if @user.phone.present?
    if existing_mail_user
      flash.notice =
          "Vi har allerede registrert #{existing_mail_user.name} (#{existing_mail_user.email}) fra før."
      if existing_mail_user.member
        flash.alert = "#{existing_mail_user.name} er allerede medlem!"
        redirect_to login_path
        return
      end
      @user = existing_mail_user
      @user.attributes = params[:user]
    end

    if @user.invalid? && (@user.errors.keys & %i[email phone postal_code address]).any?
      return redirect_to signup_guide_contact_info_path, alert: ''
    end

    return redirect_to signup_guide_guardians_path if @user.age < 18 && !@user.guardian_1&.contact_info?

    redirect_to signup_guide_groups_path
  end

  def groups
    return if load_signup

    if request.post?
      store_signup
      return redirect_to signup_guide_contact_info_path if params[:back]

      return complete
    end
    @groups = Group.active.to_a
    return if @user.groups.any?

    @groups.each do |g|
      @user.groups << g if (g.from_age..g.to_age).cover?(@user.age)
    end
  end

  def complete
    Signup.transaction do
      # group_ids = params[:user].delete(:group_ids)
      if (existing_user_id = params[:user][:id].presence)
        user = User.find(existing_user_id)
        user.update! params[:user]
      else
        user = User.create! params[:user]
      end

      agent = NkfAgent.new(:signup)
      trial_form_page = agent.new_trial_form
      submit_form(trial_form_page, 'ks_bli_medlem', mapped_changes, :new_trial)

      # trial_form.frm_29_v03 = user.first_name
      # trial_form.frm_29_v04 = user.last_name
      # trial_form.frm_29_v07 = user.postal_code
      # trial_form.frm_29_v08 = user.birthdate.strftime('%d.%m.%Y')
      # trial_form.radiobutton_with(name: 'frm_29_v11', value: user.male ? 'M' : 'K').check
      # trial_form.frm_29_v13 = user.height || 10
      # trial_form.frm_29_v10 = user.contact_email
      # trial_form['frm_29_v16'] = 524 # Jujutsu (Ingen stilartstilknytning)
      # trial_form['p_ks_bli_medlem_action'] = 'OK'
      # reg_response = agent.submit(trial_form)

      logger.info reg_response.inspect
      response_doc =
          Nokogiri::XML(reg_response.body.force_encoding('ISO-8859-1').encode('UTF-8'), &:noblanks)
      logger.info response_doc.to_s

      @signup = Signup.create!(user: user)

      NkfImportTrialMembersJob.perform_later
      render :complete
    end
  end

  private

  def load_signup
    @user = if (json = cookies[:signup])
              logger.info "load_signup: #{json}"
              User.new JSON.parse(json)
            else
              User.new
            end
    if (new_attributes = params[:user])
      @user.attributes = new_attributes
    end
    @user.valid? if flash.alert
    false
  rescue => e
    logger.error e
    cookies.delete(:signup)
    redirect_to signup_guide_root_path, alert: 'Beklager!  Noe gikk galt.  Vennligst prøv på nytt.'
    true
  end

  def store_signup
    json = @user.to_json(include: :group_ids)
    logger.info "store_signup: #{json}"
    cookies[:signup] = { value: json, expires: 4.years.from_now }
  end
end
