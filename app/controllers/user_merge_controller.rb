# frozen_string_literal: true

class UserMergeController < ApplicationController
  before_action :authenticate_user

  def show
    UserImage.where(user_id: current_user.id, image_id: params[:id], rel_type: 'LIKE').first_or_create!
    redirect_to controller: :news, action: :index
  end

  def update
    UserImage.where(user_id: current_user.id, image_id: params[:id], rel_type: 'LIKE').first_or_create!
    redirect_to controller: :news, action: :index
  end
end
