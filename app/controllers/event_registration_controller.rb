# frozen_string_literal: true

class EventRegistrationController < ApplicationController
  before_action :authenticate_user, except: %i[create index new show]
  before_action except: %i[create index new show] do
    @event_invitee = EventInvitee.find(params[:id])
    admin_required if @event_invitee.user_id != current_user.id
  end

  def index
    @events = Event.upcoming.to_a
  end

  def show
    @event_invitee = EventInvitee.find(params[:id])
    return unless current_user

    admin_required if @event_invitee.user_id != current_user.id
  end

  def new
    @event_invitee = EventInvitee.new(params[:event_invitee])
    @event_invitee.user_id = current_user.id if current_user
  end

  def create
    EventInvitee.transaction do
      @event_invitee = EventInvitee.new(params[:event_invitee])
      @event_invitee.will_attend = true
      if current_user
        @event_invitee.user_id = current_user.id
      elsif @event_invitee.email.present? && (user = User.find_by(email: @event_invitee.email.strip))
        @event_invitee.user_id = user.id
      elsif @event_invitee.phone.present? &&
            (user = User.find_by(phone: @event_invitee.phone.strip.delete_prefix('+47')))
        @event_invitee.user_id = user.id
      elsif  @event_invitee.email.present? && @event_invitee.name.present?
        user = User.create! email: @event_invitee.email, name: @event_invitee.name
        @event_invitee.user_id = user.id
      end
      if @event_invitee.user_id &&
            (existing_registration = EventInvitee
                .find_by(event_id: @event_invitee.event_id, user_id: @event_invitee.user_id))
        @event_invitee = existing_registration
        redirect_to event_registration_path(@event_invitee.id)
      elsif @event_invitee.save
        unless current_user
          EventMailer.registration_confirmation(@event_invitee)
              .store(@event_invitee.user, tag: :event_registration_user)
        end
        redirect_to event_registration_path(@event_invitee.id)
      else
        render :new
      end
    end
  end

  def accept
    if @event_invitee.update(will_attend: true)
      flash[:notice] = 'Du er påmeldt.'
      redirect_to event_registration_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end

  def decline
    if @event_invitee.update(will_attend: false)
      flash[:notice] = 'Du er avmeldt.'
      redirect_to event_registration_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end

  def will_work
    if @event_invitee.update(will_work: true)
      flash[:notice] = 'Du er påmeldt!'
      redirect_to event_registration_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end

  def will_not_work
    if @event_invitee.update(will_work: false)
      flash[:notice] = 'Du vil ikke jobbe på leiren.'
      redirect_to event_registration_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end
end
