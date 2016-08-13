class BasicTechniquesController < ApplicationController
  USER_ACTIONS = [:index, :show]
  before_filter :authenticate_user, only: USER_ACTIONS
  before_filter :technical_committy_required, except: USER_ACTIONS

  def index
    @basic_techniques = BasicTechnique.includes(:rank).order(:name).to_a
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @basic_techniques }
    end
  end

  def show
    @basic_technique = BasicTechnique.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @basic_technique }
    end
  end

  def new
    @basic_technique = BasicTechnique.new
    load_form_data
    respond_to do |format|
      format.html { render :new }
      format.json { render json: @basic_technique }
    end
  end

  def edit
    @basic_technique = BasicTechnique.find(params[:id])
    load_form_data
    render :edit
  end

  def create
    @basic_technique = BasicTechnique.new(params[:basic_technique])
    respond_to do |format|
      if @basic_technique.save
        format.html { redirect_to @basic_technique, notice: 'Basic technique was successfully created.' }
        format.json { render json: @basic_technique, status: :created, location: @basic_technique }
      else
        format.html { new }
        format.json { render json: @basic_technique.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @basic_technique = BasicTechnique.find(params[:id])
    respond_to do |format|
      if @basic_technique.update_attributes(params[:basic_technique])
        format.html { redirect_to @basic_technique, notice: 'Basic technique was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { edit }
        format.json { render json: @basic_technique.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @basic_technique = BasicTechnique.find(params[:id])
    @basic_technique.destroy
    respond_to do |format|
      format.html { redirect_to basic_techniques_url }
      format.json { head :no_content }
    end
  end

  private

  def load_form_data
    @wazas = Waza.all.to_a
    @ranks = Rank.includes(:martial_art).
        where(martial_arts: { name: 'Kei Wa Ryu' }).order(:position).to_a
  end
end
