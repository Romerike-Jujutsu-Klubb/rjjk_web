# frozen_string_literal: true

class ImagesController < ApplicationController
  PUBLIC_ACTIONS = %i[blurred gallery inline show].freeze
  PERSONAL_ACTIONS = %i[create mine new upload].freeze
  before_action :admin_required, except: PUBLIC_ACTIONS + PERSONAL_ACTIONS
  before_action :authenticate_user, only: PERSONAL_ACTIONS

  caches_page :show, :inline, :blurred
  cache_sweeper :image_sweeper, only: %i[update destroy]

  def index
    @images = Image.without_image.order(created_at: :desc).to_a
  end

  def show
    image = Image
        .select(%i[id cloudinary_identifier cloudinary_transformed_at content_length content_type name
                   user_id google_drive_reference md5_checksum])
        .find(params[:id])
    return if rank_required(image)

    requested_format = params[:format]
    return if !serving_webp(requested_format) && !serving_webm(requested_format) &&
        (redirected_to_webp(image, requested_format) || redirected_to_webm(image, requested_format) ||
            redirected_to_format(image, requested_format))

    return if redirected_to_cloudinary(image)

    if image.video?
      streamer = image.content_data_io
      headers['Content-Type'] = image.content_type
      headers['Content-disposition'] = "inline; filename=\"#{image.name}\""
      self.response_body = streamer
      return
    end

    image_content = image.content_data_io
    return redirect_to_icon(image) if image_content.nil?

    if requested_format == image.format
      send_data(image_content.string, disposition: 'inline', type: image.content_type,
          filename: image.name)
    else
      send_image(image, MiniMagick::Image.read(image_content), requested_format)
    end
  rescue => e
    logger.error e
    logger.error e.backtrace.join("\n")
    redirect_to_icon(image)
  end

  def inline
    image = Image.select('cloudinary_identifier,id,name,content_type,user_id,google_drive_reference')
        .find(params[:id])
    return if rank_required(image)

    requested_format = params[:format]
    return if !serving_webp(requested_format) &&
        (redirected_to_webp(image, requested_format) || redirected_to_icon(image) ||
            redirected_to_format(image, requested_format))

    width = params[:width].to_i
    width = 492 if width < 8
    return if redirected_to_cloudinary(image, width: width)

    content_data_io = image.content_data_io
    return redirect_to_icon(image) if content_data_io.nil?

    magick_image = MiniMagick::Image.read content_data_io
    ratio = width.to_f / magick_image.width
    magick_image.resize("#{width}x#{(magick_image.height * ratio).round}")
    send_image(image, magick_image, requested_format)
  end

  def blurred
    image = Image.select('id,name,content_type,user_id,google_drive_reference').find(params[:id])
    return if rank_required(image, check_referer: false)

    requested_format = params[:format]

    return if !serving_webp(requested_format) &&
        (redirected_to_webp(image, requested_format) || redirected_to_icon(image) ||
            redirected_to_format(image, requested_format))

    content_data_io = image.content_data_io
    return redirect_to_icon(image) if content_data_io.nil?

    begin
      magick_image = MiniMagick::Image.read content_data_io
      content_data_io.close
      img = magick_image.radial_blur 10
      send_image(image, img, requested_format)
    rescue => e
      logger.error e
      logger.error e.backtrace.join("\n")
      redirect_to_icon(image)
    end
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

  def reset_google_drive_reference
    @image = Image.find(params[:id])
    if @image.google_drive_reference.present?
      if @image.google_drive_io.eof?
        if @image.update(google_drive_reference: nil)
          flash.notice = 'Google drive referanse er nullstilt.'
          GoogleDriveUploadJob.perform_later(@image.id)
        else
          flash.alert = 'Kunne ikke nullstille Google Drive referansen.'
        end
      else
        flash.alert = 'Bildet er ikke tomt.'
      end
    else
      flash.alert = 'Bildet har ingen Google Drive referanse.'
      GoogleDriveUploadJob.perform_later(@image.id)
    end
    redirect_to edit_image_path(@image.id)
  end

  def destroy
    Image.find(params[:id]).destroy!
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
    image_select = gallery_query
    image_select = image_select.where(approved: true) unless admin?
    image_select = image_select.where(public: true) unless user?
    @image = image_select.where(id: params[:id]).first || image_select.first
    @images = image_select.to_a
  end

  def mine
    image_select = gallery_query.includes(:user_like).where(user_id: current_user.id)
    @images = image_select.to_a
    @image = Image.find_by(id: params[:id]) || @images.first
    render action: :gallery
  end

  private

  def gallery_query
    Image
        .select(%i[approved cloudinary_identifier cloudinary_transformed_at content_length content_type
                   description google_drive_reference height id name public user_id width])
        .where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'")
        .order('created_at DESC')
        .includes(:user)
  end

  def rank_required(image, check_referer: true)
    referer = request.headers['HTTP_REFERER']&.gsub(/\?.*$/, '')
    if (!check_referer || [root_url, front_parallax_url].include?(referer)) &&
          FrontPageSection.exists?(image_id: image.id)
      return false
    end

    image.application_steps.each do |step|
      next unless current_user&.member.nil? ||
          step.application_image_sequence.technique_application.rank > current_user.member.next_rank

      logger.warn "REFERER: #{referer.inspect}"
      redirect_to login_path, notice: 'Du må ha høyere grad for å se på dette pensumet.'
      return true
    end
    false
  end

  def redirected_to_cloudinary(image, width: nil)
    if image.cloudinary_identifier
      redirect_to helpers.image_url_with_cl(image, width: width)
      return true
    end
    CloudinaryUploadJob.perform_later(image.id)
    false
  end

  def send_image(image, magick_image, requested_format)
    content_type, filename = convert_to_format(image, magick_image, requested_format)
    send_data(magick_image.to_blob, disposition: 'inline', type: content_type, filename: filename)
  end

  def convert_to_format(image, magick_image, requested_format)
    filename = image.name
    content_type = image.content_type

    if requested_format != image.format
      begin
        magick_image.format requested_format
        filename.sub!(/\.[^.]+$/, ".#{requested_format}")
        content_type = "image/#{requested_format}"
      rescue => e
        logger.error "Exception converting image #{image.id} from #{image.format} to #{requested_format}"
        logger.error e
        logger.error e.backtrace.join("\n")
      end
    end
    [content_type, filename]
  end

  def redirected_to_webp(image, requested_format)
    return unless image.image?
    return unless helpers.accepts_webp? && !requests_webp(requested_format)

    redirect_to width: params[:width], format: :webp
    true
  end

  def redirected_to_webm(image, requested_format)
    return unless image.video?
    return if requests_webm(requested_format) || !helpers.accepts_webm?

    if image.content_length > 40.megabytes && image.cloudinary_transformed_at.nil?
      CloudinaryTransformJob.perform_later(image.id)
      return
    end

    redirect_to width: params[:width], format: :webm
    true
  end

  def requests_webp(requested_format)
    (requested_format == 'webp')
  end

  def requests_webm(requested_format)
    (requested_format == 'webm')
  end

  def serving_webp(requested_format)
    helpers.accepts_webp? && requests_webp(requested_format)
  end

  def serving_webm(requested_format)
    helpers.accepts_webm? && requests_webm(requested_format)
  end

  def redirect_to_icon(image)
    icon_name = image&.video? ? 'video-icon-tran.png' : 'pdficon_large.png'
    redirect_to helpers.asset_path icon_name
  end

  def redirected_to_icon(image)
    if image.image?
      # No redirect
    elsif image.video?
      redirect_to helpers.asset_path 'video-icon-tran.png'
      true
    elsif image.content_type == 'application/msword'
      redirect_to helpers.asset_path 'msword-icon.png'
      true
    elsif image.content_type == 'application/pdf'
      redirect_to helpers.asset_path 'pdficon_large.png'
      true
    end
  end

  def redirected_to_format(image, requested_format)
    return if requested_format && requested_format == image.format

    redirect_to width: params[:width], format: image.format
    true
  end
end
