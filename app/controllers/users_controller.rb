# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :admin_required

  def index
    @users = User.order(Arel.sql('UPPER(last_name), UPPER(first_name), email, phone, id')).to_a
  end

  def show
    respond_to do |format|
      format.vcf do
        user = User.find(params[:id])
        send_data user.to_vcard, filename: "#{user.id}.vcf", type: 'text/vcard'
      end
      format.html { edit }
    end
  end

  def photo
    user = User.with_deleted.find(params[:id])
    if user&.member&.image?
      redirect_to user.member.image
    else
      render text: 'Bilde mangler'
    end
  end

  def edit
    @user ||= User.with_deleted.find(params[:id])
    if (@member = @user.member)
      @groups =
          Group.includes(:martial_art).order('martial_arts.name, groups.name').where(closed_on: nil).to_a
      @groups |= @member.groups
    end
    @users = User.order(:first_name, :last_name, :email, :phone).to_a
    lookup_context.prefixes.prepend 'members'
    render :edit
  ensure
    lookup_context.prefixes.delete 'members'
  end

  def create
    @user = User.new(user_params)
    if @user.save
      back_or_redirect_to @user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def update
    @user = User.with_deleted.find(params[:id])
    form = params[:user].delete(:form)
    logger.warn "User form: #{form}" if form
    if @user.update params[:user]
      flash.notice = 'Brukeren er oppdatert.'
      unless Rails.env.development?
        [@user, *@user.contactees, *@user.payees, *@user.primary_wards, *@user.secondary_wards]
            .map(&:member).compact.each do |member|
          NkfMemberSyncJob.perform_later member
        end
      end
      back_or_redirect_to edit_user_path(@user)
    else
      flash.now.alert = "En feil oppsto ved lagring av brukeren: #{@user.errors.full_messages.join("\n")}"
      edit
    end
  end

  def move_attribute
    @user = User.with_deleted.find(params[:id])
    other_user = User.with_deleted.find(params[:other_user_id])
    attribute = params[:attribute]
    User.transaction do
      raise "#{attribute} not blank" if other_user[attribute].present?

      other_user[attribute] = @user[attribute]
      @user[attribute] = nil
      @user.save! validate: false
      other_user.save! validate: false
      flash.notice = 'Brukeren er oppdatert.'
      unless Rails.env.development?
        [@user, *@user.contactees, *@user.payees, *@user.primary_wards, *@user.secondary_wards]
            .map(&:member).compact.each do |member|
          NkfMemberSyncJob.perform_later member
        end
      end
      back_or_redirect_to edit_user_path(@user)
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy!
    redirect_to @user
  end

  def restore
    @user = User.with_deleted.find(params[:id])
    @user.restore!
    redirect_to @user
  end

  protected

  def protect?(action)
    !%w[login signup forgot_password].include?(action)
  end

  # Generate a template user for certain actions on get
  def generate_blank_form
    case request.method
    when 'GET'
      @user = User.new params[:user]
      render
      true
    else
      false
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user)
        .permit(:name, :email, :phone)
  end
end
