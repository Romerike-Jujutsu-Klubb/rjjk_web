# frozen_string_literal: true
class EventInviteesController < ApplicationController
  before_filter :admin_required, except: [:index, :show]

  def index
    @event_invitees = EventInvitee.order(:name).to_a

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @event_invitees }
    end
  end

  def show
    @event_invitee = EventInvitee.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event_invitee }
    end
  end

  def new
    @event_invitee = EventInvitee.new params[:event_invitee]
    load_users

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event_invitee }
    end
  end

  def edit
    @event_invitee = EventInvitee.find(params[:id])
    load_users
  end

  def create
    @event_invitee = EventInvitee.new(params[:event_invitee])

    respond_to do |format|
      if @event_invitee.save
        format.html do
          back_or_redirect_to(@event_invitee, notice: 'Event invitee was successfully created.')
        end
        format.json { render json: @event_invitee, status: :created, location: @event_invitee }
      else
        load_users
        format.html { render action: 'new' }
        format.json { render json: @event_invitee.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @event_invitee = EventInvitee.find(params[:id])

    respond_to do |format|
      if @event_invitee.update_attributes(params[:event_invitee])
        format.html do
          back_or_redirect_to(@event_invitee, notice: 'Event invitee was successfully updated.')
        end
        format.json { head :no_content }
      else
        load_users
        format.html { render action: 'edit' }
        format.json { render json: @event_invitee.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event_invitee = EventInvitee.find(params[:id])
    @event_invitee.destroy

    respond_to do |format|
      format.html { back_or_redirect_to event_invitees_url }
      format.json { head :no_content }
    end
  end

  private

  def load_users
    @users = [@event_invitee.user].compact + (User.order(:first_name, :last_name).to_a - @event_invitee.event.users)
  end
end
