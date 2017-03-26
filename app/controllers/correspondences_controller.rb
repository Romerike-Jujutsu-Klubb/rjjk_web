# frozen_string_literal: true
class CorrespondencesController < ApplicationController
  def index
    @correspondences = Correspondence.all
  end

  def show
    @correspondence = Correspondence.find(params[:id])
  end

  def new
    @correspondence = Correspondence.new
  end

  def edit
    @correspondence = Correspondence.find(params[:id])
  end

  def create
    @correspondence = Correspondence.new(params[:correspondence])
    if @correspondence.save
      redirect_to @correspondence, notice: 'Correspondence was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @correspondence = Correspondence.find(params[:id])
    if @correspondence.update_attributes(params[:correspondence])
      redirect_to @correspondence, notice: 'Correspondence was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @correspondence = Correspondence.find(params[:id])
    @correspondence.destroy
    redirect_to correspondences_url
  end
end
