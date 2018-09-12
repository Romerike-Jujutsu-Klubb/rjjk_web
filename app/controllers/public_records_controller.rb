# frozen_string_literal: true

class PublicRecordsController < ApplicationController
  before_action :admin_required

  def index
    @public_records = PublicRecord.order('created_at DESC').to_a
  end

  def show
    @public_record = PublicRecord.find(params[:id])
  end

  def new
    @public_record = PublicRecord.new
  end

  def edit
    @public_record = PublicRecord.find(params[:id])
  end

  def create
    @public_record = PublicRecord.new(params[:public_record])
    if @public_record.save
      redirect_to @public_record, notice: 'Public record was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @public_record = PublicRecord.find(params[:id])
    if @public_record.update(params[:public_record])
      redirect_to @public_record, notice: 'Public record was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @public_record = PublicRecord.find(params[:id])
    @public_record.destroy
    redirect_to public_records_url
  end
end
