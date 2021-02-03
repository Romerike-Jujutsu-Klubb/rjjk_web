# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :admin_required, except: %i[calendar index show]

  def index
    @events = Event.order('start_at DESC').to_a
  end

  def show
    @event = Event.find(params[:id])

    if current_user
      @event_invitee = @event.event_invitees.find { |ei| ei.user_id == current_user.id }
    elsif @event.private?
      render file: "#{Rails.root}/public/404", layout: false, status: :not_found
    end
  end

  def preview
    I18n.locale = params[:preview_locale]
    @event = Event.new(params[:event])
    @event.id ||= params[:id] || 42
    @event.created_at ||= Time.current
    @event.start_at ||= @event.created_at
    @event_invitee = EventInvitee.new(id: 0, event: @event, user: User.new(name: 'Bruce Lee'))
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
    @event ||= Event.includes(event_invitees: %i[invitation signup_confirmation signup_rejection user])
        .find(params[:id])
    @groups =
        Group.where('closed_on IS NULL OR closed_on >= ?', @event.start_at&.to_date || Date.current).to_a
    @external_candidates = EventInvitee.includes(:event, user: :memberships)
        .where.not(user_id: @event.event_invitees.map(&:user_id))
        .where.not(organization: EventInvitee::INTERNAL_ORG)
        .where(members: { id: nil })
        .group_by(&:user)
        .group_by { |_u, invs| invs[0].organization }
        .to_a
    render action: 'edit'
  end

  def create
    @event = Event.new(params[:event])
    @event.groups = params[:group][:id].map { |group_id| Group.find(group_id) } if params[:group]

    if @event.save
      flash[:notice] = 'Arrangement ble opprettet.'
      redirect_to edit_event_path(@event)
    else
      render action: 'new'
    end
  end

  def update
    @event = Event.find(params[:id])
    @event.attributes = params[:event] if params[:event]
    @event = @event.becomes(@event.type.constantize) if @event.type_changed?
    if @event.save
      selected_members =
          @event.groups.map(&:members).map { |m| m.includes(:user) }.map(&:active).flatten.uniq
      selected_users = selected_members.map(&:user).compact.uniq
      missing_users = selected_users - @event.users
      missing_users.each do |u|
        EventInvitee.create!(event: @event, user_id: u.id)
      end
      flash[:notice] = 'Event was successfully updated.'
      back_or_redirect_to action: :edit
    else
      flash.now.alert = "Kunne ikke lagre arrangementet: #{@event.errors.full_messages.join('  ')}"
      edit
    end
  end

  def add_org
    event = Event.find(params[:id])
    organization = params[:organization]
    user_ids = params[:user_ids]

    Event.transaction do
      user_ids.each { |user_id| event.event_invitees.create! organization: organization, user_id: user_id }
      flash.notice = "La til #{user_ids.size}#{" for #{organization}" if organization.present?}."
    rescue => e
      flash.alert = "Kunne ikke legge til deltakere.: #{e}"
    end
    redirect_to edit_event_path(event, anchor: :historic_tab)
  end

  def accept
    @event = Event.find(params[:id])
    invitee = @event.event_invitees.find { |ei| ei.user_id == current_user.id }
    if invitee.update(will_attend: true)
      flash[:notice] = 'Du er påmeldt.'
      back_or_redirect_to @event
    else
      redirect_back fallback_location: root_path
    end
  end

  def decline
    @event = Event.find(params[:id])
    invitee = @event.event_invitees.find { |ei| ei.user_id == current_user.id }
    if invitee.update(will_attend: false, will_work: nil)
      flash[:notice] = 'Du er avmeldt.'
      back_or_redirect_to @event
    else
      flash.alert = 'Beklager!  Kunne ikke melde deg av.'
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
      event_invitee = event.event_invitees.for_user(current_user.id)&.first ||
          EventInvitee.new(event: event, user: current_user)
      event_invitee.id = -event.id
      recipients = [event_invitee]
    elsif params[:recipients] == 'members'
      recipients = Group.all.to_a.map { |g| g.members.active(event.start_at.to_date) }
          .flatten.compact.uniq
    elsif params[:recipients] == 'candidates'
      recipients = event.event_invitees.reject do |ei|
        ei.will_attend || ei.invitation || ei.signup_confirmation || ei.signup_rejection
      end
    elsif params[:recipients] == 'invited'
      recipients = event.event_invitees.reject do |ei|
        ei.will_attend || ei.signup_confirmation || ei.signup_rejection
      end
    elsif params[:recipients] == 'groups'
      recipients = event.groups.map(&:members).flatten
    end
    now = Time.current
    recipients.each do |ei|
      event_invitee_message = EventInviteeMessage.new(
          event_invitee: ei, message_type: EventMessage::MessageType::INVITATION, ready_at: now
        )
      if params[:example]
        event_invitee_message.id = -event.id
        EventMailer.event_invitee_message(event_invitee_message).store(ei.user, tag: :event_invite)
      else
        event_invitee_message.save!
      end
    end
    UserMessageSenderJob.perform_now if params[:example]
    redirect_to edit_event_path(event, anchor: :invited_tab), notice: 'Invitasjon er sendt.'
  end

  def calendar
    event_id = params[:id]
    if event_id
      events = []
      if (event = Event.find_by(id: event_id))
        events << event
      end
      if (graduation = Graduation.find_by(id: event_id))
        events << GraduationEvent.new(graduation)
      end
    else
      today = Time.zone.today
      events = Event
          .where('(end_at IS NOT NULL AND end_at >= ?) OR start_at >= ?', today, today)
          .order(:start_at, :end_at).to_a +
          Graduation.where('held_on >= ?', today).order(:held_on).map { |g| GraduationEvent.new(g) }
    end

    cal = Icalendar::Calendar.new
    env_prefix = ("#{Rails.env}." unless Rails.env.production?)

    events.each do |e|
      cal.event do |ce|
        ce.uid = "#{e.class.name.underscore}.#{e.id}@#{env_prefix}jujutsu.no"
        ce.dtstart = Icalendar::Values::Date.new(e.start_at)
        ce.dtend = Icalendar::Values::Date.new(e.end_at || e.start_at)
        ce.summary = e.name
        if e.description
          ce.description = Kramdown::Document
              .new(e.description.strip, html_to_native: true).to_kramdown
              .gsub(/\{:.*?\}\s*/, '')
        end
        ce.ip_class = 'PRIVATE'

        ce.alarm do |a|
          a.action = 'DISPLAY' # This line isn't necessary, it's the default
          a.summary = 'Alarm notification'
          a.trigger = '-P1DT0H0M0S' # 1 day before
        end
        ce.alarm do |a|
          a.action = 'DISPLAY'
          a.summary = 'Alarm notification' # email subject (required)
          a.description = e.name
          a.trigger = '-PT15M' # 15 minutes before
        end
        ce.alarm do |a|
          a.action = 'DISPLAY'
          a.summary = 'Alarm notification' # email subject (required)
          a.description = e.name
          a.trigger = '-PT1H15M' # 15 minutes before
        end
        ce.alarm do |a|
          a.action = 'AUDIO'
          a.trigger = '-PT15M'
          a.append_attach 'Basso'
        end
      end
    end

    cal.publish

    respond_to do |format|
      format.ics do
        send_data(cal.to_ical, filename: 'RJJK.ics',
                              disposition: 'inline; filename=RJJK.ics', type: 'text/calendar')
      end
      format.all do
        send_data(cal.to_ical, filename: 'RJJK.ics',
                              disposition: 'inline; filename=RJJK.ics', type: 'text/calendar')
      end
    end
  end
end
