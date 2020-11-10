# frozen_string_literal: true

class FrontPageSectionsController < ApplicationController
  before_action :admin_required
  before_action :set_front_page_section, only: %i[show edit update destroy]

  def index
    @front_page_sections = FrontPageSection.order(:position).to_a
  end

  def show
    edit
  end

  def new
    @front_page_section = FrontPageSection.new
    load_form_data
    render :new
  end

  def edit
    load_form_data
    render :edit
  end

  def create
    @front_page_section = FrontPageSection.new(front_page_section_params)

    if @front_page_section.save
      redirect_to front_page_sections_path, notice: 'Front page section was successfully created.'
    else
      new
    end
  end

  def update
    if @front_page_section.update(front_page_section_params)
      redirect_to @front_page_section, notice: 'Front page section was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @front_page_section.destroy
    redirect_to front_page_sections_url, notice: 'Front page section was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_front_page_section
    @front_page_section = FrontPageSection.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def front_page_section_params
    params.require(:front_page_section)
        .permit(:title, :subtitle, :image_id, :button_text, :information_page_id)
  end

  def load_form_data
    @images = Image.order(:name).to_a
    @information_pages = InformationPage.order(:title).to_a
  end
end
