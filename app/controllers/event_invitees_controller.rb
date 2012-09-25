class EventInviteesController < ApplicationController
  # GET /event_invitees
  # GET /event_invitees.json
  def index
    @event_invitees = EventInvitee.order(:name).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @event_invitees }
    end
  end

  # GET /event_invitees/1
  # GET /event_invitees/1.json
  def show
    @event_invitee = EventInvitee.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event_invitee }
    end
  end

  # GET /event_invitees/new
  # GET /event_invitees/new.json
  def new
    @event_invitee = EventInvitee.new params[:event_invitee]
    @users = User.order(:first_name, :last_name).all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event_invitee }
    end
  end

  # GET /event_invitees/1/edit
  def edit
    @event_invitee = EventInvitee.find(params[:id])
    @users = User.order(:first_name, :last_name).all
  end

  # POST /event_invitees
  # POST /event_invitees.json
  def create
    @event_invitee = EventInvitee.new(params[:event_invitee])

    respond_to do |format|
      if @event_invitee.save
        format.html { back_or_redirect_to @event_invitee, notice: 'Event invitee was successfully created.' }
        format.json { render json: @event_invitee, status: :created, location: @event_invitee }
      else
        @users = User.order(:first_name, :last_name).all
        format.html { render action: "new" }
        format.json { render json: @event_invitee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /event_invitees/1
  # PUT /event_invitees/1.json
  def update
    @event_invitee = EventInvitee.find(params[:id])

    respond_to do |format|
      if @event_invitee.update_attributes(params[:event_invitee])
        format.html { back_or_redirect_to @event_invitee, notice: 'Event invitee was successfully updated.' }
        format.json { head :no_content }
      else
        @users = User.order(:first_name, :last_name).all
        format.html { render action: "edit" }
        format.json { render json: @event_invitee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_invitees/1
  # DELETE /event_invitees/1.json
  def destroy
    @event_invitee = EventInvitee.find(params[:id])
    @event_invitee.destroy

    respond_to do |format|
      format.html { redirect_to event_invitees_url }
      format.json { head :no_content }
    end
  end
end
