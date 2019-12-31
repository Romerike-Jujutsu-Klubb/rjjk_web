# frozen_string_literal: true

class BasicTechniquesController < ApplicationController
  USER_ACTIONS = %i[index show].freeze
  before_action :authenticate_user, only: USER_ACTIONS
  before_action :technical_committy_required, except: USER_ACTIONS

  def index
    @basic_techniques = BasicTechnique.includes(:rank).order(:name).to_a
  end

  def show
    @basic_technique = BasicTechnique.find(params[:id])
  end

  def new
    @basic_technique ||= BasicTechnique.new(params[:basic_technique])
    load_form_data
    render :new
  end

  def edit
    @basic_technique = BasicTechnique.find(params[:id])
    load_form_data
    render :edit
  end

  def create
    @basic_technique = BasicTechnique.new(params[:basic_technique])
    if @basic_technique.save
      redirect_to edit_rank_path(@basic_technique.rank_id), notice: 'Opprettet ny grunnteknikk.'
    else
      new
    end
  end

  def update
    @basic_technique = BasicTechnique.find(params[:id])
    if @basic_technique.update(params[:basic_technique])
      redirect_to edit_rank_path(@basic_technique.rank_id), notice: 'Oppdaterte grunnteknikk.'
    else
      edit
    end
  end

  def destroy
    @basic_technique = BasicTechnique.find(params[:id])
    @basic_technique.destroy
    redirect_to basic_techniques_url
  end

  private

  def load_form_data
    @wazas = Waza.order(:name).to_a
    @ranks = Rank.includes(:martial_art)
        .where(martial_arts: { name: 'Kei Wa Ryu' }).order(:position).to_a
  end
end
