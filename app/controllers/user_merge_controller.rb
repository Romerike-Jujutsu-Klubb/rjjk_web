# frozen_string_literal: true

class UserMergeController < ApplicationController
  before_action :admin_required

  def show
    @user = User.find(params[:id])
    return unless (other_user_id = params[:other_user_id])

    @other_user = User.find(other_user_id)
  end

  def update
    user = User.find(params[:id])
    redirect_to user
  end
end
