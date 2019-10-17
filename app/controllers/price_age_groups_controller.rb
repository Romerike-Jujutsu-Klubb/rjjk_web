# frozen_string_literal: true

class PriceAgeGroupsController < ApplicationController
  before_action :admin_required
  before_action :set_price_age_group, only: %i[show edit update destroy]

  # GET /price_age_groups
  # GET /price_age_groups.json
  def index
    @price_age_groups = PriceAgeGroup.all
  end

  # GET /price_age_groups/1
  # GET /price_age_groups/1.json
  def show; end

  # GET /price_age_groups/new
  def new
    @price_age_group = PriceAgeGroup.new
  end

  # GET /price_age_groups/1/edit
  def edit; end

  # POST /price_age_groups
  # POST /price_age_groups.json
  def create
    @price_age_group = PriceAgeGroup.new(price_age_group_params)

    respond_to do |format|
      if @price_age_group.save
        format.html { redirect_to @price_age_group, notice: 'Price age group was successfully created.' }
        format.json { render :show, status: :created, location: @price_age_group }
      else
        format.html { render :new }
        format.json { render json: @price_age_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /price_age_groups/1
  # PATCH/PUT /price_age_groups/1.json
  def update
    respond_to do |format|
      if @price_age_group.update(price_age_group_params)
        format.html { redirect_to @price_age_group, notice: 'Price age group was successfully updated.' }
        format.json { render :show, status: :ok, location: @price_age_group }
      else
        format.html { render :edit }
        format.json { render json: @price_age_group.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @price_age_group.destroy
    redirect_to price_age_groups_url, notice: 'Price age group was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_price_age_group
    @price_age_group = PriceAgeGroup.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def price_age_group_params
    params.require(:price_age_group).permit(:name, :from_age, :to_age, :yearly_fee, :monthly_fee)
  end
end
