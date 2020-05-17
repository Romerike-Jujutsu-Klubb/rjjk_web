# frozen_string_literal: true

class TechniqueLinksController < ApplicationController
  before_action :admin_required

  def index
    @technique_links = TechniqueLink.all
  end

  def show
    @technique_link = TechniqueLink.find(params[:id])
  end

  def new
    @technique_link ||= TechniqueLink.new(params[:technique_link])
    load_form_data
    render action: :new
  end

  def edit
    @technique_link ||= TechniqueLink.find(params[:id])
    load_form_data
    render action: :edit
  end

  def create
    @technique_link = TechniqueLink.new(params[:technique_link])
    if @technique_link.save
      redirect_to @technique_link.linkable, notice: 'Lagret lenke.'
    else
      new
    end
  end

  def update
    @technique_link = TechniqueLink.find(params[:id])
    if @technique_link.update(params[:technique_link])
      redirect_to @technique_link.linkable, notice: 'Opdaterte lenke.'
    else
      edit
    end
  end

  def destroy
    @technique_link = TechniqueLink.find(params[:id])
    @technique_link.destroy
    redirect_to edit_polymorphic_path(@technique_link.linkable)
  end

  private

  def load_form_data
    @linkables = (@technique_link.linkable_type&.constantize || BasicTechnique).order(:name).to_a
  end
end
