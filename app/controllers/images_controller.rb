# frozen_string_literal: true

class ImagesController < ApplicationController
  PUBLIC_ACTIONS = %i[gallery inline show].freeze
  PERSONAL_ACTIONS = %i[create mine new upload].freeze
  before_action :admin_required, except: PUBLIC_ACTIONS + PERSONAL_ACTIONS
  before_action :authenticate_user, only: PERSONAL_ACTIONS

  caches_page :show, :inline
  cache_sweeper :image_sweeper, only: %i[update destroy]

  def index
    @images = Image.all
  end

  def show
    image = Image.select('id, content_type, name, user_id, google_drive_reference').find(params[:id])
    if params[:format].nil?
      redirect_to width: params[:width], format: image.format
      return
    end
    if image.video?
      streamer = image.content_data_io
      headers['Content-Type'] = image.content_type
      headers['Content-disposition'] = "inline; filename=\"#{image.name}\""
      self.response_body = streamer
    else
      image_content = image.load_content
      send_data(image_content, disposition: 'inline', type: image.content_type, filename: image.name)
    end
  end

  JAVA_IMAGE_EXCPTIONS =
      if RUBY_ENGINE == 'jruby'
        [java.lang.NullPointerException, java.lang.OutOfMemoryError, javax.imageio.IIOException,
         Java::JavaLang::ArrayIndexOutOfBoundsException]
      else
        []
      end

  def inline
    @image = Image.select('id,name,content_type,user_id,google_drive_reference').find(params[:id])
    if params[:format].nil?
      redirect_to width: params[:width], format: @image.format
      return
    end
    if @image.video?
      redirect_to ActionController::Base.helpers.asset_path 'video-icon-tran.png'
      return
    end
    if @image.content_type == 'application/msword'
      redirect_to ActionController::Base.helpers.asset_path 'msword-icon.png'
      return
    end
    if @image.content_type == 'application/pdf'
      redirect_to ActionController::Base.helpers.asset_path 'pdficon_large.png'
      return
    end
    begin
      imgs = Magick::ImageList.new
      imgs.from_blob @image.load_content
    rescue *JAVA_IMAGE_EXCPTIONS => e
      logger.error "Exception loading image: #{e.class} #{e}"
      icon_name = @image.video? ? 'video-icon-tran.png' : 'pdficon_large.png'
      redirect_to ActionController::Base.helpers.asset_path icon_name
      return
    end
    width = params[:width].to_i
    width = 492 if width < 8
    img_width = imgs.first.columns
    ratio = width.to_f / img_width
    imgs.each { |img| img.crop_resized!(width, img.rows * ratio) }
    send_data(imgs.to_blob, disposition: 'inline', type: @image.content_type, filename: @image.name)
  end

  def new
    @image ||= Image.new(params[:image])
  end

  def create
    @image = Image.new(params[:image])
    if @image.save
      flash[:notice] = "Lastet opp nytt bilde **#{@image.name}**."
      back_or_redirect_to action: :gallery, id: @image.id
    else
      render action: :new
    end
  end

  def upload
    image_params = params[:image]
    image_params.delete(:file).each { |file| @image = Image.create! image_params.merge file: file }
    redirect_to action: :gallery, id: @image.id
  end

  def edit
    @image ||= Image.find(params[:id])
    begin
      @image.update_dimensions! unless @image.video?
    rescue
      @image.width = 320
      @image.height = 240
    end
  end

  def update
    @image = Image.find(params[:id])
    if @image.update_attributes(params[:image])
      flash.notice = 'Bildet ble oppdatert.'
      back_or_redirect_to action: :edit, id: @image
    else
      flash.now.warning = 'Bildet kunne ikke oppdateres.'
      render action: 'edit'
    end
  end

  def destroy
    Image.find(params[:id]).destroy
    back_or_redirect_to action: :index
  end

  def image_list
    @images = Image.where("name NOT LIKE '%.MP4'").order('UPPER(name)').to_a
    render layout: false
  end

  def media_list
    media_extensions = %w[mp4 mov flv]
    @media = Image
        .where(media_extensions.map { |e| "UPPER(name) LIKE '%.#{e.upcase}'" }.join(' OR '))
        .order('UPPER(name)').to_a
    render layout: false
  end

  def gallery
    image_select = Image.select(%i[approved content_type description id name public user_id])
        .where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'")
        .order('created_at DESC')
    image_select = image_select.includes(:user)
    image_select = image_select.where('approved = ?', true) unless admin?
    image_select = image_select.where('public = ?', true) unless user?
    @image = image_select.where(id: params[:id]).first || image_select.first
    @images = image_select.to_a
  end

  def mine
    image_select = Image.select(%i[approved content_type description id name public user_id])
        .where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'")
        .order('created_at DESC')
    image_select = image_select.where('user_id = ?', current_user.id)
    image_select = image_select.includes(:user)
    @images = image_select.to_a
    @image = Image.find_by(id: params[:id]) || @images.first
    render action: :gallery
  end
end
