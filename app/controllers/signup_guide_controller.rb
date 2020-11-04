# frozen_string_literal: true

class SignupGuideController < ApplicationController
  include NkfForm

  layout PUBLIC_LAYOUT

  before_action do
    @layout_menu_title = 'Innmelding'
    @layout_no_footer = true
  end

  def basics
    return unless load_signup

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
    return unless load_signup

    @user.guardian_1 ||= User.new
    return unless request.post?

    store_signup
    return redirect_to signup_guide_basics_path if params[:back]
  end

  # Posted after name_and_birthdate and guardians
  def contact_info
    return unless load_signup
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

    return redirect_to signup_guide_guardians_path if @user.age&.<(18) && !@user.guardian_1&.contact_info?

    redirect_to signup_guide_groups_path
  end

  def groups
    return unless load_signup

    if request.post?
      store_signup
      return redirect_to signup_guide_contact_info_path if params[:back]

      return complete
    end
    @groups = Group.active.to_a
    return if @user.groups.any?

    @groups.each { |g| @user.groups << g if (g.from_age..g.to_age).cover?(@user.age) }
  end

  def complete
    Signup.transaction do
      if (existing_user_id = params[:user][:id].presence)
        user = User.find(existing_user_id)
        user.update! params[:user]
      else
        user = @user
        group_ids = @user.group_ids
        @user.group_ids = nil
        @user.save!
        @user.update! group_ids: group_ids
      end

      @signup = Signup.new(user: user)

      agent = NkfAgent.new(:signup)
      trial_form_page = agent.new_trial_form
      mapped_changes = @signup.mapping_attributes(:new_trial)
      submit_form(trial_form_page, 'ks_bli_medlem', mapped_changes, :new_trial,
          submit_in_development: true)
      @signup.save!
      clear_signup
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
    true
  rescue => e
    logger.error e
    cookies.delete(:signup)
    redirect_to signup_guide_root_path, alert: 'Beklager!  Noe gikk galt.  Vennligst prøv på nytt.'
    false
  end

  def store_signup
    json = @user.to_json(include: :group_ids)
    logger.info "store_signup: #{json}"
    cookies[:signup] = { value: json, expires: 100.years.from_now }
  end

  def clear_signup
    logger.info 'clear_signup'
    cookies.delete(:signup)
  end
end
