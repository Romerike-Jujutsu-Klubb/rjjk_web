# encoding: UTF-8

class EmbusController < ApplicationController
  # GET /embus
  # GET /embus.json
  def index
    if embu = Embu.last
      redirect_to :action => :edit, :id => embu.id
    else
      redirect_to :action => :new
    end
  end

  # GET /embus/1
  # GET /embus/1.json
  def show
    edit
    render :actipon => :edit
  end

  # GET /embus/new
  # GET /embus/new.json
  def new
    unless current_user
      redirect_to :controller => :welcome, :action => :index, :notice => 'Du må være logget på for å redigere din embu.'
      return
    end
    @embu = Embu.new
    load_data
    @rank = current_user.member.next_rank

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @embu }
    end
  end

  # GET /embus/1/edit
  def edit
    @embu = Embu.find(params[:id])
    load_data
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

  def update
    @embu = Embu.find(params[:id])
    if @embu.update_attributes(params[:embu])
      redirect_to :action => :edit, :id => @embu.id, notice: 'Embu was successfully updated.'
    else
      render action: "edit"
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

  private

  def load_data
    @embus = Embu.where('user_id = ?', current_user.id).all
    @ranks = Rank.order('position DESC').all
  end

end
