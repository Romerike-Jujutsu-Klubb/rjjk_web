# frozen_string_literal: true

class EventInviteesController < ApplicationController
  before_action :admin_required, except: %i[index show]

  def index
    @event_invitees =
        EventInvitee.includes(:user).references(:users).order('users.first_name, users.last_name').to_a
  end

  def show
    @event_invitee = EventInvitee.find(params[:id])
  end

  def new
    @event_invitee ||= EventInvitee.new params[:event_invitee]
    @event_invitee.user = User.new
    load_users
    render action: 'new'
  end

  def edit
    @event_invitee ||= EventInvitee.find(params[:id])
    load_users
    render action: :edit
  end

  def create
    @event_invitee = EventInvitee.new(params[:event_invitee])
    if @event_invitee.save
      back_or_redirect_to(@event_invitee, notice: 'Event invitee was successfully created.')
    else
      new
    end
  end

  def update
    @event_invitee = EventInvitee.find(params[:id])
    if @event_invitee.update(params[:event_invitee])
      back_or_redirect_to(@event_invitee, notice: 'Event invitee was successfully updated.')
    else
      edit
    end
  end

  def destroy
    @event_invitee = EventInvitee.find(params[:id])
    @event_invitee.destroy
    back_or_redirect_to event_invitees_url
  end

  private

  def load_users
    @users = User.order(:first_name, :last_name).to_a - @event_invitee.event.users
    if @event_invitee.user
      @users.prepend @event_invitee.user
    else
      if @event_invitee.email.present?
        @matching_email_user = User.with_deleted.find_by(email: @event_invitee.email.downcase)
      end
      if @event_invitee.phone.present?
        @matching_phone_user = User.with_deleted.find_by(phone: @event_invitee.phone)
      end
    end
  end
end
