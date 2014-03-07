class ElectionsController < ApplicationController
  before_filter :admin_required

  def index
    @elections = Election.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @elections }
    end
  end

  def show
    @election = Election.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @election }
    end
  end

  def new
    @election = Election.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @election }
    end
  end

  def edit
    @election = Election.find(params[:id])
    @annual_meetings = AnnualMeeting.all
    @roles = Role.
        where('years_on_the_board IS NOT NULL OR id = ?', @election.role_id).
        order(:name).all
    @members = Member.active(@election.annual_meeting.date).order(:first_name, :last_name).all
  end

  # POST /elections
  # POST /elections.json
  def create
    @election = Election.new(params[:election])

    respond_to do |format|
      if @election.save
        format.html { redirect_to @election, notice: 'Board appointment was successfully created.' }
        format.json { render json: @election, status: :created, location: @election }
      else
        format.html { render action: "new" }
        format.json { render json: @election.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /elections/1
  # PUT /elections/1.json
  def update
    @election = Election.find(params[:id])

    respond_to do |format|
      if @election.update_attributes(params[:election])
        format.html { redirect_to @election, notice: 'Board appointment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @election.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /elections/1
  # DELETE /elections/1.json
  def destroy
    @election = Election.find(params[:id])
    @election.destroy

    respond_to do |format|
      format.html { redirect_to elections_url }
      format.json { head :no_content }
    end
  end
end
