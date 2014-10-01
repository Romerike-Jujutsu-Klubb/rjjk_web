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
    load_form_data
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @election }
    end
  end

  def edit
    @election = Election.find(params[:id])
    load_form_data
  end

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

  def destroy
    @election = Election.find(params[:id])
    @election.destroy
    respond_to do |format|
      format.html { redirect_to elections_url }
      format.json { head :no_content }
    end
  end

  private

  def load_form_data
    @annual_meetings = AnnualMeeting.all
    @roles = Role.
        where('years_on_the_board IS NOT NULL OR id = ?', @election.role_id).
        order(:name).to_a
    @members = ([@election.member].compact + Member.active(@election.annual_meeting.try(:date)).
        order(:first_name, :last_name).to_a).uniq
  end

end
