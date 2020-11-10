# frozen_string_literal: true

class UserMergeController < ApplicationController
  RELATIONS = %i[embus event_invitees images memberships news_item_likes news_items payees primary_wards
                 secondary_wards user_messages].freeze
  before_action :admin_required

  def show
    @user = User.find(params[:id])
    @other_user = User.find_by(id: params[:other_user_id])
    unless @other_user
      user_names = @user.name.to_s.split(/\s+/)
      @users = (User.order(:first_name, :last_name).to_a - [@user]).sort_by do |u|
        other_names = u.name.to_s.split(/\s+/)
        [
          u.name == @user.name ? 0 : 1,
          other_names.sort == user_names.sort ? 0 : 1,
          -(other_names & user_names).size,
          u.name.to_s,
        ]
      end
    end
    render :show
  end

  def update
    @user = User.find(params[:id])
    @other_user = User.find(params[:other_user_id])

    User.transaction do
      @user.attributes = params[:user] if params[:user]
      @user.class.reflections.each do |ref_name, reflection|
        next if %w[last_attendance last_membership member].include?(ref_name)
        next unless reflection.is_a? ActiveRecord::Reflection::HasOneReflection

        user_value = @user.send(ref_name)
        other_user_value = @other_user.send(ref_name)
        next if user_value == other_user_value
        raise "Duplicate value for #{ref_name}" if user_value && other_user_value
        next if other_user_value.nil?

        other_user_value.update! reflection.foreign_key => @user.id
      end
      RELATIONS.each do |rel|
        reflection = @other_user.class.reflections[rel.to_s]
        @other_user.send(rel).each { |m| m.update! reflection.foreign_key => @user.id }
      end
      @other_user.reload
      @other_user.really_destroy!
      @user.update! params[:user] if params[:user]
      flash.notice = 'Brukerene er slått sammen.'
      unless Rails.env.development?
        [@user, *@user.contactees, *@user.payees, *@user.primary_wards, *@user.secondary_wards]
            .map(&:member).compact.each do |member|
          NkfMemberSyncJob.perform_later member
        end
      end
      redirect_to @user
    end
  rescue => e
    logger.error e
    logger.error e.backtrace.join("\n")
    flash.now.alert = 'En feil oppsto ved lagring av brukeren:' \
        " #{e}<br/>#{@user.errors.full_messages.join("\n").inspect}" \
        " #{@other_user.errors.full_messages.join("\n").inspect}"
    show
  end
end
