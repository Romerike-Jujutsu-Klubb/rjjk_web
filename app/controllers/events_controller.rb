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
      flash[:notice] = 'Event was successfully updated.'
      redirect_to(@event)
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
      recipients = [EventInvitee.new(:event => event, :name => current_user.name, :email => current_user.email)]
    elsif params[:recipients] == 'all'
      recipients = Group.all.map { |g| g.members.active(event.start_at.to_date).map { |m| m.email } }.flatten.compact.sort.uniq
    elsif params[:recipients] == 'invited'
      recipients = event.event_invitees.map{|ei| ei.email}
    elsif params[:recipients] == 'groups'
      recipients = event.groups.map{|g| g.members.map{|m| m.email}}.flatten
    end
    invitation = event.invitation
    recipients.each do |recipient|
      event_invitee_message = EventInviteeMessage.new(
          :event_invitee => recipient, :message_type => EventMessage::MessageType::INVITATION, :body => invitation.body,
          :subject => invitation.subject
      )
      event_invitee_message.id = -invitation.id
      NewsletterMailer.event_invitee_message(event_invitee_message).deliver
    end
    render :text => ''
  end
end
