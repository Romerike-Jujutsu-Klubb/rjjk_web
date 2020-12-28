# frozen_string_literal: true

class ProfileController < ApplicationController
  before_action :authenticate_user

  def index
    @user ||= current_user
    load_form_data
    render :index
  end

  def show
    index
  end

  def photo
    @user = current_user
    @return_path = profile_index_path
    render 'users/photo'
  end

  def save_image
    @user = current_user
    params.require(:imgBase64) =~ /^data:([^;]+);base64,(.*)$/
    content = Base64.decode64(Regexp.last_match(2))
    content_type = Regexp.last_match(1)
    UserImage.transaction do
      image = Image.create! user_id: current_user.id, name: "Foto #{Date.current}",
          content_type: content_type, content_data: content, content_length: content.length,
                            width: params[:width], height: params[:height]
      @user.user_images.create! image: image, rel_type: :profile
    end
    render plain: content.hash
  end

  def update
    @user = current_user
    if @user.update user_params
      flash.notice = 'Profilen din er oppdatert.'
      [@user, *@user.contactees, *@user.payees, *@user.primary_wards, *@user.secondary_wards]
          .map(&:last_membership).compact.each do |member|
        NkfMemberSyncJob.perform_later member
      end
      redirect_to edit_user_path(@user)
    else
      flash.now.alert = "En feil oppsto ved lagring av brukeren: #{@user.errors.full_messages.join("\n")}"
      edit
    end
  end

  private

  def load_form_data
    @groups =
        Group.includes(:martial_art).order('martial_arts.name, groups.name').where(closed_on: nil).to_a
    @groups |= @user.groups
    @users = User.order(:first_name, :last_name, :email, :phone).to_a if admin?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :phone, :first_name, :last_name, :address, :postal_code,
        :male, :locale, :group_ids)
  end
end
