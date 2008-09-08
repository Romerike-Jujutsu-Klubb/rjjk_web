class ImagesController < ApplicationController
  caches_page :show
  cache_sweeper :image_sweeper, :only => [:update, :destroy]
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @images = Image.paginate :page => params[:page], :per_page => 10
  end

  def show
    @image = Image.find(params[:id])
    send_data(@image.content_data,
        :disposition => 'inline',
        :type => @image.content_type,
        :filename => @image.name)
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(params[:image])
    if @image.save
      flash[:notice] = 'Image was successfully created.'
      #redirect_to :action => 'list'
      redirect_to :controller => 'info', :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @image = Image.find(params[:id])
  end

  def update
    @image = Image.find(params[:id])
    if @image.update_attributes(params[:image])
      flash[:notice] = 'Image was successfully updated.'
      redirect_to :action => :edit, :id => @image
    else
      render :action => 'edit'
    end
  end

  def destroy
    Image.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def image_list
    @images = Image.find(:all, :conditions => "name NOT LIKE '%.MP4'", :order => 'UPPER(name)')
    render :layout => false
  end

  def media_list
    @media = Image.find(:all, :conditions => "name LIKE '%.MP4'", :order => 'UPPER(name)')
    render :layout => false
  end

end
