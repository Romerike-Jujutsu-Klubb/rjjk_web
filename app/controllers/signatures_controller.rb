# frozen_string_literal: true
class SignaturesController < ApplicationController
  before_action :admin_required

  # GET /signatures
  # GET /signatures.json
  def index
    @signatures = Signature.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @signatures }
    end
  end

  # GET /signatures/1
  # GET /signatures/1.json
  def show
    @signature = Signature.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @signature }
    end
  end

  def image
    @signature = Signature.find(params[:id])
    send_data(@signature.image,
        disposition: 'inline',
        type: @signature.content_type,
        filename: @signature.name)
  end

  # GET /signatures/new
  # GET /signatures/new.json
  def new
    @signature = Signature.new
    @members = Member.active(Date.today).order(:birthdate, :first_name, :last_name).to_a

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @signature }
    end
  end

  # GET /signatures/1/edit
  def edit
    @signature = Signature.find(params[:id])
    @members = Member.active(Date.today).order(:birthdate, :first_name, :last_name).to_a
  end

  # POST /signatures
  # POST /signatures.json
  def create
    @signature = Signature.new(params[:signature])

    respond_to do |format|
      if @signature.save
        format.html { redirect_to @signature, notice: 'Signature was successfully created.' }
        format.json { render json: @signature, status: :created, location: @signature }
      else
        format.html { render action: :new }
        format.json { render json: @signature.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /signatures/1
  # PUT /signatures/1.json
  def update
    @signature = Signature.find(params[:id])

    respond_to do |format|
      if @signature.update_attributes(params[:signature])
        format.html { redirect_to @signature, notice: 'Signature was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: :edit }
        format.json { render json: @signature.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /signatures/1
  # DELETE /signatures/1.json
  def destroy
    @signature = Signature.find(params[:id])
    @signature.destroy

    respond_to do |format|
      format.html { redirect_to signatures_url }
      format.json { head :no_content }
    end
  end
end
