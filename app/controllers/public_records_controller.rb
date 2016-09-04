# frozen_string_literal: true
class PublicRecordsController < ApplicationController
  # GET /public_records
  # GET /public_records.json
  def index
    @public_records = PublicRecord.order('created_at DESC').to_a

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @public_records }
    end
  end

  # GET /public_records/1
  # GET /public_records/1.json
  def show
    @public_record = PublicRecord.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @public_record }
    end
  end

  # GET /public_records/new
  # GET /public_records/new.json
  def new
    @public_record = PublicRecord.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @public_record }
    end
  end

  # GET /public_records/1/edit
  def edit
    @public_record = PublicRecord.find(params[:id])
  end

  # POST /public_records
  # POST /public_records.json
  def create
    @public_record = PublicRecord.new(params[:public_record])

    respond_to do |format|
      if @public_record.save
        format.html do
          redirect_to @public_record, notice: 'Public record was successfully created.'
        end
        format.json { render json: @public_record, status: :created, location: @public_record }
      else
        format.html { render action: 'new' }
        format.json { render json: @public_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /public_records/1
  # PUT /public_records/1.json
  def update
    @public_record = PublicRecord.find(params[:id])

    respond_to do |format|
      if @public_record.update_attributes(params[:public_record])
        format.html do
          redirect_to @public_record, notice: 'Public record was successfully updated.'
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @public_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /public_records/1
  # DELETE /public_records/1.json
  def destroy
    @public_record = PublicRecord.find(params[:id])
    @public_record.destroy

    respond_to do |format|
      format.html { redirect_to public_records_url }
      format.json { head :no_content }
    end
  end
end
