# frozen_string_literal: true

class EventMessagesController < ApplicationController
  before_action :admin_required, except: %i[index show]

  def index
    @event_messages = EventMessage.all
  end

  def show
    @event_message = EventMessage.find(params[:id])
  end

  def new
    @event_message = EventMessage.new(params[:event_message])
    @event_message.subject ||= @event_message.event.try(:name)
    @event_message.body ||= @event_message.event.try(:description)
  end

  def edit
    @event_message = EventMessage.find(params[:id])
  end

  def create
    @event_message = EventMessage.new(params[:event_message])
    if @event_message.save
      back_or_redirect_to @event_message, notice: 'Event message was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @event_message = EventMessage.find(params[:id])
    if @event_message.update(params[:event_message])
      back_or_redirect_to @event_message, notice: 'Event message was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @event_message = EventMessage.find(params[:id])
    @event_message.destroy
    redirect_to event_messages_url
  end
end
