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
    @basic_technique_link ||= BasicTechniqueLink.new(params[:basic_technique_link])
    @basic_techniques = BasicTechnique.all
    render action: :new
  end

  def edit
    @basic_technique_link ||= BasicTechniqueLink.find(params[:id])
    @basic_techniques = BasicTechnique.all
    render action: :edit
  end

  def create
    @basic_technique_link = BasicTechniqueLink.new(params[:basic_technique_link])
    if @basic_technique_link.save
      redirect_to @basic_technique_link.basic_technique, notice: 'Lagret lenke.'
    else
      new
    end
  end

  def update
    @basic_technique_link = BasicTechniqueLink.find(params[:id])
    if @basic_technique_link.update(params[:basic_technique_link])
      redirect_to @basic_technique_link.basic_technique, notice: 'Opdaterte lenke.'
    else
      edit
    end
  end

  def destroy
    @basic_technique_link = BasicTechniqueLink.find(params[:id])
    @basic_technique_link.destroy
    redirect_to basic_technique_links_url
  end
end
