# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :admin_required, except: %i[calendar index show]

  def index
    @events = Event.order('start_at DESC').to_a
  end

  def show
    @event = Event.find(params[:id])
    @event_invitee = EventInvitee.find_by(event_id: @event.id, user_id: current_user.id)
  end

  def preview
    I18n.locale = params[:preview_locale]
    @event = Event.new(params[:event])
    @event.id = 42
    @event.created_at ||= Time.current
    @event.start_at ||= @event.created_at
    @event_invitee = EventInvitee.new(id: 0, event_id: @event.id)
    render action: :show, layout: false
  end

  def attendance_form
    @event = Event.find(params[:id])
    render layout: 'print'
  end

  def new
    @event = Event.new
  end

  def edit
    @event = Event.find(params[:id])
    @groups = Group.where('closed_on IS NULL OR closed_on >= ?', @event.start_at.to_date).to_a
  end

  def create
    @event = Event.new(params[:event])
    @event.groups = params[:group][:id].map { |group_id| Group.find(group_id) } if params[:group]

    if @event.save
      flash[:notice] = 'Event was successfully created.'
      redirect_to edit_event_path(@event)
    else
      render action: 'new'
    end
  end

  def update
    @event = Event.find(params[:id])
    @event.groups = params[:group][:id].map { |group_id| Group.find(group_id) } if params[:group]
    if @event.update(params[:event] || {})
      selected_members =
          @event.groups.map(&:members).map { |m| m.includes(:user) }.map(&:active).flatten.uniq
      selected_users = selected_members.map(&:user).compact
      missing_users = selected_users - @event.users
      missing_users.each do |u|
        EventInvitee.create!(event: @event, user_id: u.id)
      end
      flash[:notice] = 'Event was successfully updated.'
      back_or_redirect_to action: :edit
    else
      render action: 'edit'
    end
  end

  def accept
    @event = Event.find(params[:id])
    invitee = @event.event_invitees.find { |ei| ei.user_id == current_user.id }
    if invitee.update(will_attend: true)
      flash[:notice] = 'Du er påmeldt.'
      redirect_to @event
    else
      redirect_back fallback_location: root_path
    end
  end

  def decline
    @event = Event.find(params[:id])
    invitee = @event.event_invitees.find { |ei| ei.user_id == current_user.id }
    if invitee.update(will_attend: false)
      flash[:notice] = 'Du er avmeldt.'
      redirect_to @event
    else
      redirect_back fallback_location: root_path
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to(events_url)
  end

  def invite
    event = Event.find(params[:id])
    if params[:example]
      recipients = [current_user]
    elsif params[:recipients] == 'all'
      recipients = Group.all.to_a.map { |g| g.members.active(event.start_at.to_date) }
          .flatten.compact.uniq
    elsif params[:recipients] == 'invited'
      recipients = event.event_invitees
    elsif params[:recipients] == 'groups'
      recipients = event.groups.map(&:members).flatten
    end
    recipients.each do |recipient|
      event_invitee = EventInvitee.new(event: event, name: recipient.name, email: recipient.email)
      event_invitee_message = EventInviteeMessage.new(
          event_invitee: event_invitee, message_type: EventMessage::MessageType::INVITATION
        )
      event_invitee_message.id = -event.id
      NewsletterMailer.event_invitee_message(event_invitee_message)
          .store(recipient, tag: :event_invite)
    end
    render plain: ''
  end

  def calendar
    event_id = params[:id]
    cal = RiCal.Calendar do
      if event_id
        events = [Event, Graduation].flat_map { |clas| clas.where(id: event_id).to_a }
      else
        today = Time.zone.today
        events = Event
            .where('(end_at IS NOT NULL AND end_at >= ?) OR start_at >= ?', today, today)
            .order(:start_at, :end_at).to_a +
            Graduation.where('held_on >= ?', today).order(:held_on).to_a
      end
      events.each do |e|
        event do
          env_prefix = ("#{Rails.env}." unless Rails.env.production?)
          uid "#{e.class.name.underscore}.#{e.id}@#{env_prefix}jujutsu.no"
          summary e.name
          if e.description
            description Kramdown::Document
                .new(e.description.strip, html_to_native: true).to_kramdown
                .gsub(/\{:.*?\}\s*/, '')
          end
          dtstart e.start_at
          dtend e.end_at || e.start_at
          # location "Datek Wireless AS, Instituttveien, Kjeller"
          # add_attendee "uwe@kubosch.no"
          alarm do
            description e.name
          end
        end
      end
    end
    respond_to do |format|
      format.ics do
        send_data(cal.export, filename: 'RJJK.ics',
                              disposition: 'inline; filename=RJJK.ics', type: 'text/calendar')
      end
      format.all do
        send_data(cal.export, filename: 'RJJK.ics',
                              disposition: 'inline; filename=RJJK.ics', type: 'text/calendar')
      end
    end
  end
end
