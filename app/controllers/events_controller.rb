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

    if @event.save
      flash[:notice] = 'Event was successfully created.'
      redirect_to(@event)
    else
      render :action => "new"
    end
  end

  def update
    @event = Event.find(params[:id])
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
      recipients = [current_user.email]
    elsif params[:recipients] == 'all'
      recipients = Group.all.map { |g| g.members.active(event.start_at.to_date).map { |m| m.email } }.flatten.compact.sort.uniq
    end
    recipients.each do |recipient|
      NewsletterMailer.event_invitation(event, recipient).deliver
    end
    render :text => ''
  end
end
