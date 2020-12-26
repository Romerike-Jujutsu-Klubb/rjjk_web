# frozen_string_literal: true

class UserImagesController < ApplicationController
  before_action :authenticate_user

  def use
    user_image = UserImage.find(params[:id])
    user_image.update! updated_at: Time.current
    redirect_to photo_user_path(user_image.user_id)
  end

  def like
    UserImage.where(user_id: current_user.id, image_id: params[:id], rel_type: 'LIKE').first_or_create!
    redirect_to controller: :news, action: :index
  end
end
