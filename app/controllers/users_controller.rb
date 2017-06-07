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
    @user = User.find_by(id: params[:id]) || current_user
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
          @user.attributes = user_params
          flash.now['notice'] = 'User has been updated.' if @user.save
        when 'change_password'
          change_password
        when 'delete'
          delete
          return
        else
          raise 'unknown edit action'
        end
      rescue => ex
        logger.warn ex
        logger.warn ex.backtrace
      end
    end
    redirect_to action: :edit
  end

  def delete
    @user = current_user || User.find_by(id: session[:user_id])
    begin
      @user.update(deleted: true)
      self.current_user = nil
    rescue => ex
      flash.now['message'] = "Error: #{ex}."
      back_or_redirect_to '/'
    end
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
    @user = (params[:id] && User.find_by(id: params[:id])) || current_user ||
        User.find_by(id: session[:user_id])
    @members = Member.select('id, first_name, last_name').where(email: @user.email).to_a
    case request.method
    when 'GET'
      render action: :edit
      true
    else
      false
    end
  end

  def report_exception(ex)
    logger.warn ex
    logger.warn ex.backtrace.join("\n")
  end
end
