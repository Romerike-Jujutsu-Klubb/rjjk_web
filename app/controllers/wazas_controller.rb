# frozen_string_literal: true

class WazasController < ApplicationController
  before_action :admin_required

  def index
    @wazas = Waza.all
  end

  def show
    @waza = Waza.find(params[:id])
  end

  def new
    @waza = Waza.new
  end

  def edit
    @waza = Waza.find(params[:id])
  end

  def create
    @waza = Waza.new(params[:waza])
    if @waza.save
      redirect_to @waza, notice: 'Waza was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @waza = Waza.find(params[:id])
    if @waza.update(params[:waza])
      redirect_to @waza, notice: 'Waza was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @waza = Waza.find(params[:id])
    @waza.destroy
    redirect_to wazas_url
  end
end
