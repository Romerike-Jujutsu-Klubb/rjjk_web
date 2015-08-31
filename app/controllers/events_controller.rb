# encoding: utf-8
class EventsController < ApplicationController
  before_filter :admin_required, :except => [:calendar, :index, :show]

  def index
    @events = Event.order('start_at DESC').to_a
  end

  def show
    @event = Event.find(params[:id])
  end

  def attendance_form
    @event = Event.find(params[:id])
    render :layout => 'print'
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
      redirect_to(@event)
    else
      render :action => 'new'
    end
  end

  def update
    @event = Event.find(params[:id])
    @event.groups = params[:group][:id].map { |group_id| Group.find(group_id) } if params[:group]
    if @event.update_attributes(params[:event])
      selected_members = @event.groups.map(&:members).flatten.uniq
      selected_users = selected_members.map(&:user).compact
      missing_users = selected_users - @event.users
      missing_users.each do |u|
        EventInvitee.create!(:event => @event, :user_id => u.id)
      end
      flash[:notice] = 'Event was successfully updated.'
      redirect_to :action => :edit
    else
      render :action => 'edit'
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
      recipients = Group.all.to_a.map { |g| g.members.active(event.start_at.to_date) }.flatten.compact.uniq
    elsif params[:recipients] == 'invited'
      recipients = event.event_invitees
    elsif params[:recipients] == 'groups'
      recipients = event.groups.map { |g| g.members }.flatten
    end
    recipients.each do |recipient|
      event_invitee = EventInvitee.new(:event => event, :name => recipient.name, :email => recipient.email)
      event_invitee_message = EventInviteeMessage.new(
          :event_invitee => event_invitee, :message_type => EventMessage::MessageType::INVITATION)
      event_invitee_message.id = -event.id
      NewsletterMailer.event_invitee_message(event_invitee_message).deliver_now
    end
    render :text => ''
  end

  def calendar
    event_id = params[:id]
    cal = RiCal.Calendar do
      if event_id
        events = [Event.find(event_id)]
      else
        events = Event.order(:start_at, :end_at)
      end
      events.each do |e|
        event do
          uid "event#{e.id}@jujutsu.no"
          summary e.name
          description RedCloth.new(e.description.strip).to_plain if e.description
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
      format.ics { send_data(cal.export, :filename => 'RJJK.ics', :disposition => 'inline; filename=RJJK.ics', :type => 'text/calendar') }
      format.all do
        send_data(cal.export, filename: 'RJJK.ics', disposition: 'inline; filename=RJJK.ics', type: 'text/calendar')
      end
    end
  end

end
