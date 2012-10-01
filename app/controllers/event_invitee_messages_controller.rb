class EventInviteeMessagesController < ApplicationController
  before_filter :admin_required, :except => [:index, :show]

  # GET /event_invitee_messages
  # GET /event_invitee_messages.json
  def index
    @event_invitee_messages = EventInviteeMessage.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @event_invitee_messages }
    end
  end

  # GET /event_invitee_messages/1
  # GET /event_invitee_messages/1.json
  def show
    @event_invitee_message = EventInviteeMessage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event_invitee_message }
    end
  end

  # GET /event_invitee_messages/new
  # GET /event_invitee_messages/new.json
  def new
    @event_invitee_message = EventInviteeMessage.new params[:event_invitee_message]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event_invitee_message }
    end
  end

  # GET /event_invitee_messages/1/edit
  def edit
    @event_invitee_message = EventInviteeMessage.find(params[:id])
  end

  # POST /event_invitee_messages
  # POST /event_invitee_messages.json
  def create
    @event_invitee_message = EventInviteeMessage.new(params[:event_invitee_message])

    respond_to do |format|
      if @event_invitee_message.save
        format.html { back_or_redirect_to @event_invitee_message, notice: 'Signup confirmation was successfully created.' }
        format.json { render json: @event_invitee_message, status: :created, location: @event_invitee_message }
      else
        format.html { render action: "new" }
        format.json { render json: @event_invitee_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /event_invitee_messages/1
  # PUT /event_invitee_messages/1.json
  def update
    @event_invitee_message = EventInviteeMessage.find(params[:id])

    respond_to do |format|
      if @event_invitee_message.update_attributes(params[:event_invitee_message])
        format.html { back_or_redirect_to @event_invitee_message, notice: 'Signup confirmation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event_invitee_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_invitee_messages/1
  # DELETE /event_invitee_messages/1.json
  def destroy
    @event_invitee_message = EventInviteeMessage.find(params[:id])
    @event_invitee_message.destroy

    respond_to do |format|
      format.html { redirect_to event_invitee_messages_url }
      format.json { head :no_content }
    end
  end
end
