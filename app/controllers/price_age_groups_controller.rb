# frozen_string_literal: true

class PriceAgeGroupsController < ApplicationController
  before_action :admin_required
  before_action :set_price_age_group, only: %i[show edit update destroy]

  def index
    @price_age_groups = PriceAgeGroup.order(:from_age).to_a
  end

  def show
    edit
  end

  def new
    @price_age_group = PriceAgeGroup.new
  end

  def edit
    render :edit
  end

  def create
    @price_age_group = PriceAgeGroup.new(price_age_group_params)

    if @price_age_group.save
      redirect_to @price_age_group, notice: 'Price age group was successfully created.'
    else
      render :new
    end
  end

  def update
    if @price_age_group.update(price_age_group_params)
      redirect_to @price_age_group, notice: 'Price age group was successfully updated.'
    else
      edit
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
