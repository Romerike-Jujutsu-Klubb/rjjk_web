# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :admin_required

  def index
    @users = User.order(Arel.sql('UPPER(last_name), UPPER(first_name), email, phone, id')).to_a
  end

  def show
    edit
  end

  def edit
    @user ||= User.with_deleted.find(params[:id])
    if (@member = @user.member)
      @groups = Group.includes(:martial_art).order('martial_arts.name, groups.name').where(closed_on: nil)
          .to_a
      @groups |= @member.groups
      @users = User.order(:last_name, :first_name, :email, :phone).to_a
      lookup_context.prefixes.prepend 'members'
    end
    render action: :edit
  ensure
    lookup_context.prefixes.delete 'members'
  end

  def update
    @user = User.with_deleted.find(params[:id])
    form = params[:user].delete(:form)
    logger.warn "User form: #{form}" if form
    if @user.update params[:user]
      flash.notice = 'Brukeren er oppdatert.'
      back_or_redirect_to edit_user_path(@user)
    else
      flash.now.alert = 'En feil oppsto ved lagring av brukeren.'
      edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy!
    back_or_redirect_to users_path
  end

  def like
    UserImage.where(user_id: current_user.id, image_id: params[:id], rel_type: 'LIKE').first_or_create!
    redirect_to controller: :news, action: :index
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
end
