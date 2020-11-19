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
    return redirect_to signup_guide_guardians_path if @user.age&.<(18)

    redirect_to signup_guide_contact_info_path
  end

  def guardians
    return unless load_signup

    @user.guardian_1 ||= User.new
    return unless request.post?

    store_signup
    return redirect_to signup_guide_basics_path if params[:back]
    if @user.invalid? && (@user.errors.keys & %i[guardian_1_id]).any?
      return redirect_to signup_guide_guardians_path, alert: ''
    end

    redirect_to signup_guide_contact_info_path
  end

  def find_user
    if (phone_query = params[:phone]).present?
    users = User.where('phone ILIKE ?', "#{phone_query}%")
    response = users.map do |u|
      {
        value: u.phone, text: "#{u.phone} #{u.name}", id: u.id, phone: u.phone, email: u.email,
        name: u.name, birthdate: u.birthdate, male: u.male, address: u.address, postal_code: u.postal_code
      }
    end
    else
      response = []
    end

    render json: response
  end

  # Posted after name_and_birthdate and guardians
  def contact_info
    return unless load_signup

    @user.address ||= @user.guardian_1&.address
    @user.postal_code ||= @user.guardian_1&.postal_code
    return unless request.post?

    store_signup
    if params[:back]
      return redirect_to @user.age < 18 ? signup_guide_guardians_path : signup_guide_basics_path
    end

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

    @groups.each { |g| @user.groups << g if g.conains_age(@user.age) }
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

      user.address ||= user.guardian_1&.address
      user.postal_code ||= user.guardian_1&.postal_code
      @signup = Signup.new(user: user)

      agent = NkfAgent.new(:signup)
      trial_form_page = agent.new_trial_form
      mapped_changes = @signup.mapping_attributes(:new_trial)
      logger.info "Submitting new member trial to NKF: #{mapped_changes}"
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
    if @user.guardian_1_id.nil? && (guardian_1_json = cookies[:signup_guardian_1])
      logger.info "load_signup: guardian_1: #{guardian_1_json}"
      guardian_1_attributes = JSON.parse(guardian_1_json)
      if (g1_id = guardian_1_attributes['id'])
        @user.guardian_1 = User.find g1_id
      elsif (g1_phone = guardian_1_attributes['phone'])
        @user.guardian_1 = User.find_by phone: g1_phone
      end
      if @user.guardian_1_id.nil? && (g1_email = guardian_1_attributes['email'])
        @user.guardian_1 = User.find_by email: g1_email
      end
      @user.guardian_1 ||= User.new guardian_1_attributes
    end
    if (new_attributes = params[:user])
      @user.attributes = new_attributes
    end
    @user.valid? if flash.alert
    true
  rescue => e
    logger.error e
    cookies.delete(:signup)
    cookies.delete(:signup_guardian_1)
    redirect_to signup_guide_root_path, alert: 'Beklager!  Noe gikk galt.  Vennligst prøv på nytt.'
    false
  end

  def store_signup
    json = @user.attributes.select { |_k, v| v.present? || v == false }.to_json(include: :group_ids)
    logger.info "store_signup: #{json}"
    cookies[:signup] = { value: json, expires: 100.years.from_now }
    return unless @user.guardian_1&.new_record?

    guardian_1_json = @user.guardian_1.attributes.select { |_k, v| v.present? || v == false }.to_json
    logger.info "store_signup: guardian_1: #{guardian_1_json}"
    cookies[:signup_guardian_1] = { value: guardian_1_json, expires: 100.years.from_now }
  end

  def clear_signup
    logger.info 'clear_signup'
    cookies.delete(:signup)
    cookies.delete(:signup_guardian_1)
  end
end
