require 'rubygems'
require 'RMagick'

class ImagesController < ApplicationController
  caches_page :show, :inline
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

  def inline
    @image = Image.find(params[:id])
    image = Magick::Image.from_blob(@image.content_data).first
    send_data(image.thumbnail(492.0 / image.columns).to_blob,
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
    media_extensions = %w{mp4 mov flv}
    @media = Image.find(:all, :conditions => media_extensions.map{|e|"UPPER(name) LIKE '%.#{e.upcase}'"}.join(' OR '), :order => 'UPPER(name)')
    render :layout => false
  end

end
