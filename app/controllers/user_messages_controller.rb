# frozen_string_literal: true

class UserMessagesController < ApplicationController
  before_action :authenticate_user
  before_action :set_user_message, only: %i[show edit update destroy]
  before_action do |_request|
    access_denied if @user_message && !admin? && @user_message.user_id != current_user.id
  end

  def index
    query = UserMessage.includes(user: :member).order(created_at: :desc)
    query = query.where(user_id: current_user.id) unless admin?
    @user_messages = query.limit(1000).to_a
  end

  def show
    return unless @user_message.read_at.nil? && @user_message.user_id == current_user.id

    @user_message.update! read_at: Time.current
  end

  def new
    @user_message = UserMessage.new(params[:user_message])
    load_form_data
  end

  def edit
    load_form_data
  end

  def create
    @user_message = UserMessage.new(user_message_params)
    if @user_message.save
      UserMessageSenderJob.perform_later
      redirect_to @user_message, notice: 'User message was successfully created.'
    else
      render :new
    end
  end

  def update
    if @user_message.update(user_message_params)
      redirect_to @user_message, notice: 'User message was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @user_message.destroy
    redirect_to user_messages_url, notice: 'User message was successfully destroyed.'
  end

  private

  def load_form_data
    @users = User.order(:first_name, :last_name).to_a
    @tags = UserMessage.order(:tag).distinct.pluck(:tag)
    @senders = UserMessage.distinct.pluck(:from).flatten.uniq.sort
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user_message
    @user_message = UserMessage.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_message_params
    params.require(:user_message)
        .permit(:user_id, :tag, :from, :subject, :key, :html_body, :plain_body, :sent_at, :read_at)
  end
end
