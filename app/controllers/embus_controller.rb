class EmbusController < ApplicationController
  # GET /embus
  # GET /embus.json
  def index
    @embu = Embu.last || Embu.new
    redirect_to @embu
  end

  # GET /embus/1
  # GET /embus/1.json
  def show
    @embu = Embu.find(params[:id])
    @embus = Embu.where('user_id = ?', current_user.id).all
    @ranks = Rank.all

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @embu }
    end
  end

  # GET /embus/new
  # GET /embus/new.json
  def new
    @embu = Embu.new
    @embus = Embu.where('user_id = ?', current_user.id).all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @embu }
    end
  end

  # GET /embus/1/edit
  def edit
    @embu = Embu.find(params[:id])
    @embus = Embu.where('user_id = ?', current_user.id).all
  end

  # POST /embus
  # POST /embus.json
  def create
    @embu = Embu.new(params[:embu].merge(:user_id => current_user.id))

    respond_to do |format|
      if @embu.save
        format.html { redirect_to @embu, notice: 'Embu was successfully created.' }
        format.json { render json: @embu, status: :created, location: @embu }
      else
        format.html { render action: "new" }
        format.json { render json: @embu.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /embus/1
  # PUT /embus/1.json
  def update
    @embu = Embu.find(params[:id])

    respond_to do |format|
      if @embu.update_attributes(params[:embu])
        format.html { redirect_to @embu, notice: 'Embu was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @embu.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /embus/1
  # DELETE /embus/1.json
  def destroy
    @embu = Embu.find(params[:id])
    @embu.destroy

    respond_to do |format|
      format.html { redirect_to embus_url }
      format.json { head :no_content }
    end
  end
end
