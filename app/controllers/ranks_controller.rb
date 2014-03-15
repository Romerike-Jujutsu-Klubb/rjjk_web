class RanksController < ApplicationController
  before_filter :admin_required

  def index
    @ranks = Rank.order(:martial_art_id, :position).all
    @martial_arts = @ranks.group_by(&:martial_art)
  end

  def show
    @rank = Rank.find(params[:id])
  end

  def new
    @rank ||= Rank.new
    @martial_arts = MartialArt.all(:order => 'name')
    @groups = Group.all(:order => 'from_age')
  end

  def create
    @rank = Rank.new(params[:rank])
    if @rank.save
      flash[:notice] = 'Rank was successfully created.'
      redirect_to :action => 'index'
    else
      new
      render :action => 'new'
    end
  end

  def edit
    @rank ||= Rank.find(params[:id])
    @martial_arts = MartialArt.all(:order => 'name')
    @groups = Group.all(:order => 'from_age')
    render :action => 'edit'
  end

  def update
    @rank = Rank.find(params[:id])
    if @rank.update_attributes(params[:rank])
      flash[:notice] = 'Rank was successfully updated.'
      redirect_to :action => :index
    else
      edit
    end
  end

  def destroy
    Rank.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
