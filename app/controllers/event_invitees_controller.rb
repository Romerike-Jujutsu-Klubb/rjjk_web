# frozen_string_literal: true

class EventInviteesController < ApplicationController
  before_action :admin_required, except: %i[index show]

  def index
    @event_invitees = EventInvitee.order(:name).to_a
  end

  def show
    @event_invitee = EventInvitee.find(params[:id])
  end

  def new
    @event_invitee ||= EventInvitee.new params[:event_invitee]
    load_users
    render action: 'new'
  end

  def edit
    @event_invitee = EventInvitee.find(params[:id])
    load_users
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
      load_users
      render action: 'edit'
    end
  end

  def destroy
    @event_invitee = EventInvitee.find(params[:id])
    @event_invitee.destroy
    back_or_redirect_to event_invitees_url
  end

  private

  def load_users
    @users = [@event_invitee.user].compact +
        (User.order(:first_name, :last_name).to_a - @event_invitee.event.users)
  end
end
