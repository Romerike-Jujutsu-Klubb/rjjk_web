# frozen_string_literal: true

class SignupController < ApplicationController
  # FIXME(uwe): Bruke egen layout uten distraherende elementer?

  layout PUBLIC_LAYOUT

  before_action do
    @layout_menu_title = 'Innmelding'
    @layout_no_footer = true
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
    @groups = Group.active.to_a
    return unless @user.groups.empty?

    @groups.each do |g|
      @user.group_ids << g.id if (g.from_age..g.to_age).cover? @user.age
    end
  end

  def complete
    Signup.transaction do
      group_ids = params[:user].delete(:group_ids)
      user = User.create! params[:user]
      user.group_ids = group_ids
      user.save!
      @signup = Signup.create(user: user)
    end
  end
end
