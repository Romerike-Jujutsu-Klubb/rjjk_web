# frozen_string_literal: true
class BasicTechniqueLinksController < ApplicationController
  before_action :admin_required

  def index
    @basic_technique_links = BasicTechniqueLink.all
  end

  def show
    @basic_technique_link = BasicTechniqueLink.find(params[:id])
  end

  def new
    @basic_technique_link = BasicTechniqueLink.new
  end

  def edit
    @basic_technique_link = BasicTechniqueLink.find(params[:id])
  end

  def create
    @basic_technique_link = BasicTechniqueLink.new(params[:basic_technique_link])
    if @basic_technique_link.save
      redirect_to @basic_technique_link, notice: 'Basic technique link was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @basic_technique_link = BasicTechniqueLink.find(params[:id])
    if @basic_technique_link.update_attributes(params[:basic_technique_link])
      redirect_to @basic_technique_link, notice: 'Basic technique link was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @basic_technique_link = BasicTechniqueLink.find(params[:id])
    @basic_technique_link.destroy
    redirect_to basic_technique_links_url
  end
end
