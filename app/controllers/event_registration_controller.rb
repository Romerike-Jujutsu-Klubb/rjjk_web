# frozen_string_literal: true

class EventRegistrationController < ApplicationController
  invisible_captcha only: :create
  before_action :authenticate_user, except: %i[create index new show]
  before_action except: %i[create index new show] do
    @event_invitee = EventInvitee.find(params[:id])
    admin_required if @event_invitee.user_id != current_user.id
  end

  def index
    @events = Event.upcoming.order(:start_at).to_a
  end

  def show
    @event_invitee = EventInvitee.find(params[:id])
    return unless current_user

    admin_required if @event_invitee.user_id != current_user.id
  end

  def new
    @event_invitee ||= EventInvitee.new(params[:event_invitee])
    @event_invitee.user ||= (current_user || User.new)
    @upcoming_events = Event.upcoming.order(:start_at).to_a
    render :new
  end

  def create
    EventInvitee.transaction do
      @event_invitee = EventInvitee.new(params[:event_invitee])
      @event_invitee.will_attend = true

      user = current_user ||
          (@event_invitee.email.present? && User.find_by('email ILIKE ?', @event_invitee.email.strip)) ||
          (@event_invitee.phone.present? &&
                  User.find_by(phone: @event_invitee.phone.strip.delete_prefix('+47'))) ||
          (@event_invitee.email.present? && @event_invitee.email.match?(User::EMAIL_REGEXP) &&
                  @event_invitee.name.present? &&
              User.create!(email: @event_invitee.email, name: @event_invitee.name, locale: I18n.locale))
      @event_invitee.user_id = user.id if user

      if @event_invitee.user_id && (existing_registration = EventInvitee
          .find_by(event_id: @event_invitee.event_id, user_id: @event_invitee.user_id))
        @event_invitee = existing_registration
        redirect_to event_registration_path(@event_invitee.id)
      elsif @event_invitee.save
        unless current_user
          EventMailer.registration_confirmation(@event_invitee)
              .store(@event_invitee.user, tag: :event_registration_user)
          flash.notice = t :event_registration_confirmation_email_sent
        end
        redirect_to event_registration_path(@event_invitee.id)
      else
        new
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
    @event_invitee.update!(will_attend: false)
    flash[:notice] = 'Du er avmeldt.'
    redirect_to event_registration_path(@event_invitee)
  rescue => e
    ExceptionNotifier.notify_exception e
    redirect_back fallback_location: root_path,
        alert: "Kunne ikke oppdatere registreringen: #{@event_invitee.errors.full_messages}"
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
