class BasicTechniquesController < ApplicationController
  # GET /basic_techniques
  # GET /basic_techniques.json
  def index
    @basic_techniques = BasicTechnique.includes(:rank).order(:name).all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @basic_techniques }
    end
  end

  # GET /basic_techniques/1
  # GET /basic_techniques/1.json
  def show
    @basic_technique = BasicTechnique.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @basic_technique }
    end
  end

  # GET /basic_techniques/new
  # GET /basic_techniques/new.json
  def new
    @basic_technique = BasicTechnique.new
    load_form_data
    respond_to do |format|
      format.html { render :new }
      format.json { render json: @basic_technique }
    end
  end

  # GET /basic_techniques/1/edit
  def edit
    @basic_technique = BasicTechnique.find(params[:id])
    load_form_data
    render :edit
  end

  # POST /basic_techniques
  # POST /basic_techniques.json
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

  # PUT /basic_techniques/1
  # PUT /basic_techniques/1.json
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

  # DELETE /basic_techniques/1
  # DELETE /basic_techniques/1.json
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
    @wazas = Waza.all
    @ranks = Rank.includes(:martial_art).
        where(martial_arts: {name: 'Kei Wa Ryu'} ).order(:position).all
  end
end
