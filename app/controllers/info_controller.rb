# frozen_string_literal: true

class InfoController < ApplicationController
  before_action :admin_required, except: %i[show show_content]

  def index
    @information_pages = InformationPage.order(:parent_id, :position).to_a
  end

  def show
    base_query = current_user ? InformationPage : InformationPage.for_all
    @information_page ||= base_query.where('UPPER(title) = ?', params[:id].upcase).first
    @information_page ||= base_query.find_by(id: params[:id].to_i)
    return if @information_page

    if (page_alias = PageAlias.where(old_path: request.path).first)
      redirect_to page_alias.new_path, status: :moved_permanently
      return
    end
    begin
      utf8_param = params[:id].encode(Encoding::ISO_8859_1)
          .force_encoding(Encoding::UTF_8)
      utf8_title = utf8_param.upcase
      if (page = base_query.where('UPPER(title) = ?', utf8_title).first)
        redirect_to page, status: :moved_permanently
        return
      end
      if (page = base_query.where('UPPER(title) = ?', utf8_title.chomp("'")).first)
        redirect_to page, status: :moved_permanently
        return
      end
    rescue ArgumentError # rubocop: disable Lint/SuppressedException
      # Protect against invalid id parameter
    end
    raise ActiveRecord::RecordNotFound
  end

  def preview
    @information_page = InformationPage.new(params[:information_page])
    @information_page.id = 42
    @information_page.created_at ||= Time.current
    render action: :show, layout: false
  end

  def move_up
    @information_page = InformationPage.find(params[:id])
    if @information_page.in_list?
      @information_page.move_higher
    else
      @information_page.insert_at
      @information_page.move_to_bottom
    end
    @information_page.save!
    redirect_to action: :index
  end

  def move_down
    @information_page = InformationPage.find(params[:id])
    if @information_page.last?
      @information_page.remove_from_list
    else
      @information_page.move_lower
    end
    @information_page.save!
    redirect_to action: :index
  end

  def show_content
    @information_page = InformationPage.find(params[:id])
    render action: :show, layout: false
  end

  def new
    @information_page = InformationPage.new
    @information_page.parent_id = params[:parent_id]
    load_images
  end

  def create
    @information_page = InformationPage.new(params[:information_page])
    set_revised_at_param
    if @information_page.save
      flash[:notice] = 'InformationPage was successfully created.'
      redirect_to action: 'show', id: @information_page
    else
      render action: 'new'
    end
  end

  def edit
    @information_page = InformationPage.find(params[:id])
    load_images
    render action: :edit
  end

  def update
    @information_page = InformationPage.find(params[:id])
    set_revised_at_param
    if @information_page.update(params[:information_page])
      flash[:notice] = 'InformationPage was successfully updated.'
      redirect_to action: 'show', id: @information_page
    else
      edit
    end
  end

  def destroy
    @information_page = InformationPage.find(params[:id])
    if @information_page.destroy
      redirect_to information_pages_path
    else
      edit
    end
  end

  private

  def load_images
    @images = Image.published.images.select('id, name, content_type').to_a
    @icon_classes = [
      'fa fa-star',
      'fa fa-image',
      'fa fa-clipboard',
      'fa fa-file-alt',
      'fa fa-info',
      'fa fa-phone',
    ]
    @icon_classes |= InformationPage.pluck(:icon_class)
    @icon_classes.uniq!
  end

  def set_revised_at_param
    return if params[:information_page].nil? || params[:information_page][:revised_at].blank?

    params[:information_page][:revised_at] = Time.current
  end
end
