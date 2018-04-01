# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :admin_required

  def index
    @users = User.order(:last_name, :first_name, :id).to_a
  end

  def show
    edit
  end

  def edit
    generate_filled_in
  end

  def update
    @user = User.find(params[:id])
    if params['user']['form']
      form = params['user'].delete('form')
      begin
        case form
        when 'edit'
          unclean_params = params['user']
          user_params =
              if current_user.admin?
                unclean_params
              else
                unclean_params.delete_if { |k, *| !User::CHANGEABLE_FIELDS.include?(k) }
              end
          if @user.update user_params
            flash.notice = 'User has been updated.'
          else
            edit
            render action: :edit
            return
          end
        when 'change_password'
          change_password
        when 'delete'
          destroy
          return
        else
          raise 'unknown edit action'
        end
      rescue => ex
        report_exception(ex)
      end
    end
    redirect_to action: :edit
  end

  def destroy
    @user = User.find(params[:id])
    @user.update!(deleted: true)
    back_or_redirect_to users_path
  end

  def like
    UserImage.where(user_id: current_user.id, image_id: params[:id], rel_type: 'LIKE')
        .first_or_create!
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

  # Generate a template user for certain actions on get
  def generate_filled_in
    @user ||= User.find(params[:id])
    case request.method
    when 'GET'
      render action: :edit
      true
    else
      false
    end
  end
end
