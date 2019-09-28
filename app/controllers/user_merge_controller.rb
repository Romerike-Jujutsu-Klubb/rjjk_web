# frozen_string_literal: true

class UserMergeController < ApplicationController
  RELATIONS = %i[embus event_invitees images memberships news_item_likes news_items payees primary_wards
                 secondary_wards user_messages].freeze
  before_action :admin_required

  def show
    @user = User.find(params[:id])
    if (@other_user = User.find_by(id: params[:other_user_id]))

    else
      @users = User.order(:first_name, :last_name).to_a - [@user]
    end
    render :show
  end

  def update
    @user = User.find(params[:id])
    @other_user = User.find(params[:other_user_id])

    User.transaction do
      @user.update! params[:user] if params[:user]
      if @user.card_key.blank? && @other_user.card_key.present?
        @other_user.card_key.update! user_id: @user.id
      end

      RELATIONS.each do |rel|
        fk = @other_user.class.reflections[rel.to_s].foreign_key
        @other_user.send(rel).each { |m| m.update! fk => @user.id }
      end
      @other_user.reload
      @other_user.destroy!
      flash.notice = 'Brukerene er slått sammen.'
      unless Rails.env.development?
        [@user, *@user.contactees, *@user.payees, *@user.primary_wards, *@user.secondary_wards]
            .map(&:member).compact.each do |member|
          NkfMemberSyncJob.perform_later member
        end
      end
      back_or_redirect_to @user
    rescue => e
      flash.now.alert = 'En feil oppsto ved lagring av brukeren:' \
          " #{e} #{@user.errors.full_messages.join("\n")}" \
          " #{e} #{@other_user.errors.full_messages.join("\n")}"
      show
    end
  end
end
