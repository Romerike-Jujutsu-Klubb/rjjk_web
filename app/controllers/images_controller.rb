# frozen_string_literal: true

class ImagesController < ApplicationController
  PUBLIC_ACTIONS = %i[gallery inline show].freeze
  PERSONAL_ACTIONS = %i[create mine new upload].freeze
  before_action :admin_required, except: PUBLIC_ACTIONS + PERSONAL_ACTIONS
  before_action :authenticate_user, only: PERSONAL_ACTIONS

  caches_page :show, :inline
  cache_sweeper :image_sweeper, only: %i[update destroy]

  def rank_required(image)
    image.application_steps.each do |step|
      if current_user&.member.nil? || step.technique_application.rank > current_user.member.next_rank
        redirect_to login_path, notice: 'Du må ha høyere grad for å se på dette pensumet.'
        return true
      end
    end
    false
  end

  def index
    @images = Image.without_image.order(created_at: :desc).to_a
  end

  def show
    image = Image.select('id, content_type, name, user_id, google_drive_reference, md5_checksum')
        .find(params[:id])
    return if rank_required(image)

    if params[:format].nil? || params[:format] != image.format
      redirect_to show_image_path(image, width: params[:width], format: image.format)
      return
    end
    if image.video?
      streamer = image.content_data_io
      headers['Content-Type'] = image.content_type
      headers['Content-disposition'] = "inline; filename=\"#{image.name}\""
      self.response_body = streamer
    else
      begin
        image_content = image.content_data_io&.string
        if image_content.nil?
          icon_name = image.video? ? 'video-icon-tran.png' : 'pdficon_large.png'
          redirect_to ActionController::Base.helpers.asset_path icon_name
          return
        end
        send_data(image_content, disposition: 'inline', type: image.content_type, filename: image.name)
      rescue => e
        logger.error e
        logger.error e.backtrace.join("\n")
        redirect_to '/assets/pdficon_large.png'
      end
    end
  end

  def inline
    image = Image.select('id,name,content_type,user_id,google_drive_reference').find(params[:id])
    return if rank_required(image)

    if params[:format].nil? || params[:format] != image.format
      redirect_to width: params[:width], format: image.format
      return
    end
    if image.video?
      redirect_to ActionController::Base.helpers.asset_path 'video-icon-tran.png'
      return
    end
    if image.content_type == 'application/msword'
      redirect_to ActionController::Base.helpers.asset_path 'msword-icon.png'
      return
    end
    if image.content_type == 'application/pdf'
      redirect_to ActionController::Base.helpers.asset_path 'pdficon_large.png'
      return
    end
    content_data_io = image.content_data_io
    if content_data_io.nil?
      icon_name = image.video? ? 'video-icon-tran.png' : 'pdficon_large.png'
      redirect_to ActionController::Base.helpers.asset_path icon_name
      return
    end
    imgs = Magick::ImageList.new
    imgs.from_blob content_data_io.string
    width = params[:width].to_i
    width = 492 if width < 8
    img_width = imgs.first.columns
    ratio = width.to_f / img_width
    imgs.each { |img| img.crop_resized!(width, img.rows * ratio) }
    send_data(imgs.to_blob, disposition: 'inline', type: image.content_type, filename: image.name)
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
      @image.update_dimensions!
    rescue
      @image.width = 320
      @image.height = 240
    end
  end

  def update
    @image = Image.find(params[:id])
    if @image.update(params[:image])
      flash.notice = 'Bildet ble oppdatert.'
      back_or_redirect_to action: :edit, id: @image
    else
      flash.now.alert = 'Bildet kunne ikke oppdateres.'
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
    image_select = Image
        .select(%i[approved content_type description google_drive_reference height id name public user_id
                   width])
        .where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'")
        .order('created_at DESC')
    image_select = image_select.includes(:user)
    image_select = image_select.where('approved = ?', true) unless admin?
    image_select = image_select.where('public = ?', true) unless user?
    @image = image_select.where(id: params[:id]).first || image_select.first
    @images = image_select.to_a
  end

  def mine
    image_select = Image
        .select(%i[approved content_type description google_drive_reference height id name public user_id
                   width])
        .where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'")
        .order('created_at DESC')
        .includes(:user_like)
    image_select = image_select.where('user_id = ?', current_user.id)
    image_select = image_select.includes(:user)
    @images = image_select.to_a
    @image = Image.find_by(id: params[:id]) || @images.first
    render action: :gallery
  end
end
