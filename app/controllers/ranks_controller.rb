class RanksController < ApplicationController
  before_filter :admin_required

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @ranks = Rank.paginate :page => params[:page], :per_page => 42, :order => 'martial_art_id, position'
  end

  def show
    @rank = Rank.find(params[:id])
  end

  def new
    @rank = Rank.new
    @martial_arts = MartialArt.find(:all, :order => 'name')
    @groups = Group.find(:all, :order => 'from_age')
  end

  def create
    @rank = Rank.new(params[:rank])
    if @rank.save
      flash[:notice] = 'Rank was successfully created.'
      redirect_to :action => 'list'
    else
      @martial_arts = MartialArt.find(:all, :order => 'name')
      render :action => 'new'
    end
  end

  def edit
    @rank ||= Rank.find(params[:id])
    @martial_arts = MartialArt.find(:all, :order => 'name')
    @groups = Group.find(:all, :order => 'from_age')
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
    redirect_to :action => 'list'
  end
end
