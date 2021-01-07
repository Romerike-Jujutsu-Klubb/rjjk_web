# frozen_string_literal: true

class SignupsController < ApplicationController
  before_action :admin_required
  before_action :set_signup, only: %i[show edit update destroy complete terminate]

  def index
    @signups = Signup.includes(:user).order(:created_at).to_a
  end

  def show; end

  def new
    @signup ||= Signup.new(params[:signup])
    @users ||= User.with_deleted.includes(:member, :signups)
        .where(members: { id: nil }, signups: { id: nil })
        .order(:first_name, :last_name).to_a
    render :new
  end

  def edit
    @users ||= [@signup.user].compact + User.with_deleted.includes(:member, :signups)
        .where(members: { id: nil }, signups: { id: nil })
        .order(:first_name, :last_name).to_a
    render :edit
  end

  def create
    @signup = Signup.new(signup_params)
    Signup.transaction do
      @signup.user&.restore!
      if @signup.save
        redirect_to signups_path, notice: 'Signup was successfully created.'
      else
        new
      end
    end
  end

  def update
    if @signup.update(signup_params)
      redirect_to signups_path, notice: 'Signup was successfully updated.'
    else
      edit
    end
  end

  def complete
    Signup.transaction do
      Member.create!(instructor: false, user_id: @signup.user_id, joined_on: Date.current)
      @signup.destroy!
    end
    redirect_to signups_path, notice: 'Medlemskapet er opprettet.'
  end

  def terminate
    @signup.destroy!
    redirect_to signups_path, notice: 'Prøvemedlemskapet er avsluttet.'
  end

  def destroy
    @signup.destroy
    redirect_to signups_url, notice: 'Signup was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_signup
    @signup ||= Signup.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def signup_params
    params.require(:signup).permit(:user_id)
  end
end
