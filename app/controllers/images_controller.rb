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
    image = Image.select('id, content_type, name').find(params[:id])
    if params[:format].nil?
      redirect_to :width => params[:width], :format => image.format
      return
    end
    if image.video?
      streamer = image.content_data_io
      headers["Content-Type"] = image.content_type
      headers["Content-disposition"] = "inline; filename=\"#{image.name}\""
      self.response_body = streamer
    else
      image_content = Image.select('id, content_data').find(params[:id])
      send_data(image_content.content_data,
                :disposition => 'inline',
                :type => image.content_type,
                :filename => image.name)
    end
  end

  def inline
    @image = Image.find(params[:id])
    if params[:format].nil?
      redirect_to :width => params[:width], :format => @image.format
      return
    end
    begin
      imgs = Magick::ImageList.new
      imgs.from_blob @image.content_data
    rescue java.lang.NullPointerException
      redirect_to @image.video? ? '/assets/video-icon-tran.png' : '/assets/pdficon_large.png'
      return
    end
    logger.info "Image size: #{imgs.size}"
    logger.info "Image cols: #{imgs.first.columns}"
    imgs.each.with_index do |im, idx|
      logger.info "Image cols #{idx}: #{im.columns}"
    end
    cols = imgs.map { |im| im.columns }
    logger.info "Image cols #{cols}"
    width = params[:width].to_i
    width = 492 if width < 8
    img_width = imgs.first.columns
    logger.info "img_width: #{img_width}"
    ratio = width.to_f / img_width
    imgs.each { |img| img.crop_resized!(width, img.rows * ratio) }
    send_data(imgs.to_blob, :disposition => 'inline', :type => @image.content_type, :filename => @image.name)
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
    @image = Image.with_image.find(params[:id])
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
    @media = Image.all(:conditions => media_extensions.map { |e| "UPPER(name) LIKE '%.#{e.upcase}'" }.join(' OR '), :order => 'UPPER(name)')
    render :layout => false
  end

  def gallery
    fields = 'approved, content_type, description, id, name, public, user_id'
    image_select = Image.select(fields).where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'")
    image_select = image_select.includes(:user)
    image_select = image_select.where('approved = ?', true) unless admin?
    image_select = image_select.where('public = ?', true) unless user?
    @image = image_select.where(:id => params[:id]).first || image_select.first
    @images = image_select.all
  end

  def mine
    raise "Nei!" unless current_user
    fields = 'approved, content_type, description, id, name, public, user_id'
    image_select = Image.select(fields).where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'")
    image_select = image_select.where('user_id = ?', current_user.id)
    image_select = image_select.includes(:user)
    @images = image_select.all
    render :action => :gallery
  end

end
