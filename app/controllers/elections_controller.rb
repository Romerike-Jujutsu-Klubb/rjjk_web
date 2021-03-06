# frozen_string_literal: true

class ElectionsController < ApplicationController
  before_action :admin_required

  def index
    @meetings = Election.includes(:annual_meeting, :role)
        .order('events.start_at DESC, years, roles.name').to_a
        .group_by(&:annual_meeting)
    respond_to do |format|
      format.html
      format.json { render json: @elections }
    end
  end

  def show
    @election = Election.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @election }
    end
  end

  def new
    @election ||= Election.new
    load_form_data
    respond_to do |format|
      format.html { render action: 'new' }
      format.json { render json: @election }
    end
  end

  def edit
    @election = Election.find(params[:id])
    load_form_data
  end

  def create
    @election = Election.new(params[:election])
    @election.years = @election.role.try(:years_on_the_board)
    respond_to do |format|
      if @election.save
        format.html do
          redirect_to @election.member.age < 15 ? edit_election_path(@election) : elections_path,
              notice: 'Board appointment was successfully created.'
        end
        format.json { render json: @election, status: :created, location: @election }
      else
        format.html { new }
        format.json { render json: @election.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @election = Election.find(params[:id])
    respond_to do |format|
      if @election.update(params[:election])
        format.html do
          redirect_to elections_path, notice: 'Board appointment was successfully updated.'
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
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
    @annual_meetings = AnnualMeeting.order(:start_at).reverse_order.to_a
    @roles = Role
        .where('years_on_the_board IS NOT NULL OR id = ?', @election.role_id)
        .order(:name).to_a
    @members = ([@election.member].compact + Member.active(@election.annual_meeting.try(:date))
        .to_a.sort_by(&:name)).uniq
  end
end
