# frozen_string_literal: true

class RanksController < ApplicationController
  USER_ACTIONS = %i[card pdf pensum show].freeze
  before_action :authenticate_user, only: USER_ACTIONS
  before_action :technical_committy_required, except: USER_ACTIONS

  def index
    @ranks = Rank.order(:martial_art_id, :position).to_a
    @martial_arts = @ranks.group_by(&:martial_art)
  end

  def show
    @rank = Rank.find(params[:id])
  end

  def new
    @rank ||= Rank.new
    @martial_arts = MartialArt.order(:name).to_a
    @groups = Group.order(:from_age).to_a
  end

  def create
    @rank = Rank.new(params[:rank])
    if @rank.save
      flash[:notice] = 'Rank was successfully created.'
      redirect_to action: :index
    else
      new
      render action: 'new'
    end
  end

  def edit
    @rank ||= Rank.find(params[:id])
    @martial_arts = MartialArt.order(:name).to_a
    @groups = Group.order(:from_age).to_a
    render :edit
  end

  def update
    @rank = Rank.find(params[:id])
    if @rank.update(params[:rank])
      flash[:notice] = 'Rank was successfully updated.'
      back_or_redirect_to @rank
    else
      edit
    end
  end

  def destroy
    Rank.find(params[:id]).destroy
    redirect_to action: 'index'
  end
end
