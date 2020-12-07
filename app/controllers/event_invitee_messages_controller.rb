# frozen_string_literal: true

class EventInviteeMessagesController < ApplicationController
  before_action :admin_required, except: :show

  def index
    @event_invitee_messages = EventInviteeMessage.order(created_at: :desc).to_a
  end

  def show
    item_id = params[:id].to_i
    if item_id >= 0
      @event_invitee_message = EventInviteeMessage.find(item_id)
      access_denied unless current_user.id == @event_invitee_message.event_invitee.user_id
    else # Test message
      event = Event.find(-item_id)
      event_invitee = EventInvitee.new(id: item_id, event: event, user_attributes: { name: 'test', email: 'test@example.com' })
      @event_invitee_message = EventInviteeMessage.new(
          event_invitee: event_invitee, message_type: EventMessage::MessageType::INVITATION
        )
      @event_invitee_message.id = 0
    end
  end

  def new
    @event_invitee_message ||= EventInviteeMessage.new params[:event_invitee_message]
    render action: 'new'
  end

  def edit
    @event_invitee_message ||= EventInviteeMessage.find(params[:id])
    render action: 'edit'
  end

  def create
    @event_invitee_message = EventInviteeMessage.new(params[:event_invitee_message])
    if @event_invitee_message.save
      back_or_redirect_to @event_invitee_message, notice: 'Signup confirmation was successfully created.'
    else
      new
    end
  end

  def update
    @event_invitee_message = EventInviteeMessage.find(params[:id])
    if @event_invitee_message.update(params[:event_invitee_message])
      back_or_redirect_to @event_invitee_message,
          notice: 'Signup confirmation was successfully updated.'
    else
      edit
    end
  end

  def destroy
    @event_invitee_message = EventInviteeMessage.find(params[:id])
    @event_invitee_message.destroy
    redirect_to event_invitee_messages_url
  end
end
