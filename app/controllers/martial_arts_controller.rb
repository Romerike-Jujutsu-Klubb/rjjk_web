# frozen_string_literal: true

class MartialArtsController < ApplicationController
  before_action :admin_required

  def index
    list
    render action: 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def list
    @martial_arts = MartialArt.paginate page: params[:page], per_page: 10
  end

  def show
    @martial_art = MartialArt.find(params[:id])
  end

  def new
    @martial_art = MartialArt.new
  end

  def create
    @martial_art = MartialArt.new(params[:martial_art])
    if @martial_art.save
      flash[:notice] = 'MartialArt was successfully created.'
      redirect_to action: :index
    else
      render action: 'new'
    end
  end

  def edit
    @martial_art = MartialArt.find(params[:id])
  end

  def update
    @martial_art = MartialArt.find(params[:id])
    if @martial_art.update_attributes(params[:martial_art])
      flash[:notice] = 'MartialArt was successfully updated.'
      redirect_to action: 'show', id: @martial_art
    else
      render action: 'edit'
    end
  end

  def destroy
    MartialArt.find(params[:id]).destroy
    redirect_to action: :index
  end
end
