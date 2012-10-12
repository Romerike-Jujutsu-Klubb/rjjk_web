class EventsController < ApplicationController
  before_filter :admin_required, :except => [:index, :show]

  def index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def edit
    @event = Event.find(params[:id])
    @groups = Group.where('closed_on IS NULL OR closed_on >= ?', @event.start_at.to_date).all
  end

  def create
    @event = Event.new(params[:event])
    @event.groups = params[:group][:id].map{|group_id| Group.find(group_id) }

    if @event.save
      flash[:notice] = 'Event was successfully created.'
      redirect_to(@event)
    else
      render :action => "new"
    end
  end

  def update
    @event = Event.find(params[:id])
    @event.groups = params[:group][:id].map{|group_id| Group.find(group_id) } if params[:group]
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
      render :action => "edit"
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
      recipients = Group.all.map { |g| g.members.active(event.start_at.to_date) }.flatten.compact.uniq
    elsif params[:recipients] == 'invited'
      recipients = event.event_invitees
    elsif params[:recipients] == 'groups'
      recipients = event.groups.map{|g| g.members}.flatten
    end
    recipients.each do |recipient|
      event_invitee = EventInvitee.new(:event => event, :name => recipient.name, :email => recipient.email)
      event_invitee_message = EventInviteeMessage.new(
          :event_invitee => event_invitee, :message_type => EventMessage::MessageType::INVITATION)
      event_invitee_message.id = -event.id
      NewsletterMailer.event_invitee_message(event_invitee_message).deliver
    end
    render :text => ''
  end
end
