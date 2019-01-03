# frozen_string_literal: true

class EmbuPartsController < ApplicationController
  before_action :set_embu_part, only: %i[show edit update destroy]

  def index
    @embu_parts = EmbuPart.all
  end

  def show; end

  def new
    @embu_part = EmbuPart.new(params[:embu_part])
  end

  def edit; end

  def create
    @embu_part = EmbuPart.new(embu_part_params)

    respond_to do |format|
      if @embu_part.save
        format.html { redirect_to @embu_part, notice: 'Embu part was successfully created.' }
        format.json { render :show, status: :created, location: @embu_part }
      else
        format.html { render :new }
        format.json { render json: @embu_part.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @embu_part.update(embu_part_params)
        format.html { redirect_to @embu_part, notice: 'Embu part was successfully updated.' }
        format.json { render :show, status: :ok, location: @embu_part }
      else
        format.html { render :edit }
        format.json { render json: @embu_part.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @embu_part.destroy
    respond_to do |format|
      format.html { redirect_to embu_parts_url, notice: 'Embu part was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_embu_part
    @embu_part = EmbuPart.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def embu_part_params
    params.require(:embu_part).permit(:embu_id, :position, :description, :image_id)
  end
end
