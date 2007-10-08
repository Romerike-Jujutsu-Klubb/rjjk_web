class CensorsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @censor_pages, @censors = paginate :censors, :per_page => 10
  end

  def show
    @censor = Censor.find(params[:id])
  end

  def new
    @censor = Censor.new
  end

  def create
    @censor = Censor.new(params[:censor])
    if @censor.save
      flash[:notice] = 'Censor was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @censor = Censor.find(params[:id])
  end

  def update
    @censor = Censor.find(params[:id])
    if @censor.update_attributes(params[:censor])
      flash[:notice] = 'Censor was successfully updated.'
      redirect_to :action => 'show', :id => @censor
    else
      render :action => 'edit'
    end
  end

  def destroy
    Censor.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
