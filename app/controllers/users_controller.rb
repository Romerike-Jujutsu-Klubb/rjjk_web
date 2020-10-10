# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :admin_required

  def index
    @users = User.includes(:last_membership, :member)
        .order(Arel.sql('UPPER(last_name), UPPER(first_name), email, phone, id')).to_a
  end

  def valid
    @user = User.find(params[:id])
    render layout: false
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

  def new
    @user ||= User.new params[:user] && user_params
    load_form_data
    render :new
  end

  def edit
    @user ||= User.with_deleted.find(params[:id])
    load_form_data
    render :edit
  end

  def create
    @user = User.new(user_params)
    if @user.save
      back_or_redirect_to @user, notice: 'User was successfully created.'
    else
      new
    end
  end

  def update
    @user = User.with_deleted.find(params[:id])
    if @user.update params[:user]
      flash.notice = 'Brukeren er oppdatert.'
      [@user, *@user.contactees, *@user.payees, *@user.primary_wards, *@user.secondary_wards]
          .map(&:member).compact.each do |member|
        NkfMemberSyncJob.perform_later member
      end
      redirect_to edit_user_path(@user)
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
      redirect_to edit_user_path(@user)
    end
  end

  def destroy
    @user = User.with_deleted.find(params[:id])
    if @user.deleted?
      @user.really_destroy!
      redirect_to users_path, notice: 'Brukeren ble slettet permanent.'
    else
      @user.destroy!
      redirect_to @user, notice: 'Brukeren ble slettet.'
    end
  end

  def restore
    @user = User.with_deleted.find(params[:id])
    @user.restore!
    redirect_to @user
  end

  protected

  def protect?(action)
    %w[login signup forgot_password].exclude?(action)
  end

  private

  def load_form_data
    @groups =
        Group.includes(:martial_art).order('martial_arts.name, groups.name').where(closed_on: nil).to_a
    @groups |= @user.groups
    @users = User.order(:first_name, :last_name, :email, :phone).to_a
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :phone, :first_name, :last_name, :address, :postal_code,
        :role, :male, :locale, :group_ids)
  end
end
