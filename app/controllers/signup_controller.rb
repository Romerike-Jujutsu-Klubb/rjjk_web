# frozen_string_literal: true

class SignupController < ApplicationController
  # FIXME(uwe): Bruke egen layout uten distraherende elementer?

  layout PUBLIC_LAYOUT

  before_action do
    @layout_menu_title = 'Innmelding'
  end

  def name_and_birthdate
    @user = User.new
  end

  def contact_info
    @user = User.new(params[:user])
    return if @user.age >= 18 || @user.guardian_1&.contact_info?

    guardians
  end

  def guardians
    @user = User.new(params[:user])
    @user.guardian_1 ||= User.new
    render :guardians
  end

  def groups
    @user = User.new(params[:user])
  end

  def complete; end
end
