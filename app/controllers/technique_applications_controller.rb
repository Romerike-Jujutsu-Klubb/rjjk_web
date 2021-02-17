# frozen_string_literal: true

class TechniqueApplicationsController < ApplicationController
  USER_ACTIONS = %i[index show].freeze
  before_action :authenticate_user, only: USER_ACTIONS
  before_action :technical_committy_required, except: USER_ACTIONS

  def index
    @technique_applications = TechniqueApplication.all
    respond_to do |format|
      format.html
      format.json { render json: @technique_applications }
    end
  end

  def show
    @technique_application = TechniqueApplication.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @technique_application }
    end
  end

  def new
    @technique_application ||= TechniqueApplication.new(params[:technique_application])
    load_form_data
    respond_to do |format|
      format.html { render :new }
      format.json { render json: @technique_application }
    end
  end

  def edit
    @technique_application = TechniqueApplication.find(params[:id])
    load_form_data
  end

  def create
    @technique_application = TechniqueApplication.new(params[:technique_application])
    respond_to do |format|
      if @technique_application.save
        format.html do
          redirect_to edit_technique_application_path(@technique_application),
              notice: 'Opprettet ny applikasjon.'
        end
        format.json do
          render json: @technique_application, status: :created, location: @technique_application
        end
      else
        format.html { new }
        format.json { render json: @technique_application.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @technique_application = TechniqueApplication.find(params[:id])
    if @technique_application.update(params[:technique_application])
      redirect_to @technique_application, notice: 'Application was successfully updated.'
    else
      render :edit
    end
  end

  def move_up
    technique_application = TechniqueApplication.find(params[:id])
    technique_application.move_higher
    redirect_to edit_rank_path(technique_application.rank, anchor: :applications)
  end

  def move_down
    technique_application = TechniqueApplication.find(params[:id])
    technique_application.move_lower
    redirect_to edit_rank_path(technique_application.rank, anchor: :applications)
  end

  def destroy
    @technique_application = TechniqueApplication.find(params[:id])
    @technique_application.destroy!
    redirect_to edit_rank_path(@technique_application.rank_id)
  end

  def report
    @year_start = params[:id] ? Date.new(params[:id].to_i, 1, 1) : Date.current.beginning_of_year
    @technique_applications = TechniqueApplication
      .where("created_at >= ?", @year_start).to_a
      .select{|ta| ta.rank.martial_art.original_martial_art_id.nil?}
      .sort_by{|ta| ta.rank}
  end

  private

  def load_form_data
    @ranks = Rank.all.to_a
  end
end
