# frozen_string_literal: true

class SignupsController < ApplicationController
  before_action :admin_required
  before_action :set_signup, only: %i[show edit update destroy]

  def index
    @signups = Signup.all
  end

  def show; end

  def new
    @signup ||= Signup.new
    load_form_data
    render :new
  end

  def edit
    load_form_data
    render :edit
  end

  def create
    @signup = Signup.new(signup_params)
    if @signup.save
      redirect_to signups_path, notice: 'Signup was successfully created.'
    else
      new
    end
  end

  def update
    if @signup.update(signup_params)
      redirect_to signups_path, notice: 'Signup was successfully updated.'
    else
      edit
    end
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
    params.require(:signup).permit(:user_id, :nkf_member_trial_id)
  end

  def load_form_data
    @users = User.order(:first_name, :last_name).to_a
    @nkf_member_trials = NkfMemberTrial.order(:fornavn, :etternavn).to_a
  end
end
