class WazasController < ApplicationController
  # GET /wazas
  # GET /wazas.json
  def index
    @wazas = Waza.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @wazas }
    end
  end

  # GET /wazas/1
  # GET /wazas/1.json
  def show
    @waza = Waza.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @waza }
    end
  end

  # GET /wazas/new
  # GET /wazas/new.json
  def new
    @waza = Waza.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @waza }
    end
  end

  # GET /wazas/1/edit
  def edit
    @waza = Waza.find(params[:id])
  end

  # POST /wazas
  # POST /wazas.json
  def create
    @waza = Waza.new(params[:waza])

    respond_to do |format|
      if @waza.save
        format.html { redirect_to @waza, notice: 'Waza was successfully created.' }
        format.json { render json: @waza, status: :created, location: @waza }
      else
        format.html { render action: 'new' }
        format.json { render json: @waza.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /wazas/1
  # PUT /wazas/1.json
  def update
    @waza = Waza.find(params[:id])

    respond_to do |format|
      if @waza.update_attributes(params[:waza])
        format.html { redirect_to @waza, notice: 'Waza was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @waza.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wazas/1
  # DELETE /wazas/1.json
  def destroy
    @waza = Waza.find(params[:id])
    @waza.destroy

    respond_to do |format|
      format.html { redirect_to wazas_url }
      format.json { head :no_content }
    end
  end
end
