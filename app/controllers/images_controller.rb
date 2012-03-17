class ImagesController < ApplicationController
  caches_page :show, :inline
  cache_sweeper :image_sweeper, :only => [:update, :destroy]
  
  def index
    list
    render :action => 'list'
  end

  def list
    @images = Image.paginate :page => params[:page], :per_page => 4
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
    if params[:format].nil?
      redirect_to :width => params[:width], :format => @image.format
      return
    end
    begin
       image = Magick::Image.from_blob(@image.content_data).first
    rescue java.lang.NullPointerException
      redirect_to @image.video? ? '/assets/video-icon-tran.png' : '/assets/pdficon_large.png'
      return
    end
    width = params[:width].to_i
    width = 492 if width < 8
    ratio = width.to_f / image.columns
    send_data(image.crop_resized!(width, image.rows * ratio).to_blob,
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
      back_or_redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def edit
    @image = Image.find(params[:id])
  end

  def update
    @image = Image.find(params[:id])
    if @image.update_attributes(params[:image])
      flash[:notice] = 'Image was successfully updated.'
      back_or_redirect_to :action => :edit, :id => @image
    else
      flash[:notice] = 'Image not updated.'
      render :action => 'edit'
    end
  end

  def destroy
    Image.find(params[:id]).destroy
    back_or_redirect_to :action => 'list'
  end
  
  def image_list
    @images = Image.all(:conditions => "name NOT LIKE '%.MP4'", :order => 'UPPER(name)')
    render :layout => false
  end

  def media_list
    media_extensions = %w{mp4 mov flv}
    @media = Image.all(:conditions => media_extensions.map{|e|"UPPER(name) LIKE '%.#{e.upcase}'"}.join(' OR '), :order => 'UPPER(name)')
    render :layout => false
  end

end
