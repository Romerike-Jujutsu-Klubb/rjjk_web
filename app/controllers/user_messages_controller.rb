# frozen_string_literal: true
class UserMessagesController < ApplicationController
  before_action :authenticate_user
  before_action :set_user_message, only: [:show, :edit, :update, :destroy]
  before_action do |_request|
    if @user_message && !admin? && @user_message.user_id != current_user.id
      access_denied
    end
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
    @user_message = UserMessage.new
  end

  def edit; end

  def create
    @user_message = UserMessage.new(user_message_params)

    respond_to do |format|
      if @user_message.save
        format.html { redirect_to @user_message, notice: 'User message was successfully created.' }
        format.json { render :show, status: :created, location: @user_message }
      else
        format.html { render :new }
        format.json { render json: @user_message.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user_message.update(user_message_params)
        format.html { redirect_to @user_message, notice: 'User message was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_message }
      else
        format.html { render :edit }
        format.json { render json: @user_message.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user_message.destroy
    respond_to do |format|
      format.html do
        redirect_to user_messages_url, notice: 'User message was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_message
    @user_message = UserMessage.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_message_params
    params.require(:user_message)
        .permit(:user_id, :tag, :from, :subject, :key, :body, :sent_at, :read_at)
  end
end
