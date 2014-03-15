class InfoController < ApplicationController
  before_filter :admin_required, :except => [:index, :show, :show_content]

  def index
    @information_pages = InformationPage.paginate :page => params[:page], :per_page => 10
  end

  def show
    @information_page ||= InformationPage.where('UPPER(title) = ?', UnicodeUtils.upcase(params[:id])).first
    @information_page ||= InformationPage.find_by_id(params[:id].to_i)
    if @information_page.nil? && (page_alias = PageAlias.where(old_path: request.path).first)
      redirect_to page_alias.new_path, :status => :moved_permanently
      return
    end
    raise ActiveRecord::RecordNotFound unless @information_page
  end

  def move_down
    @information_page = InformationPage.find(params[:id])
    @information_page.move_lower
    @information_page.save!
    render :action => :show
  end

  def show_content
    @information_page = InformationPage.find(params[:id])
    render :action => :show, :layout => false
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
      redirect_to :action => 'show', :id => @information_page
    else
      render :action => 'new'
    end
  end

  def edit
    @information_page = InformationPage.find(params[:id])
    load_images
  end

  def update
    @information_page = InformationPage.find(params[:id])
    set_revised_at_param
    if @information_page.update_attributes(params[:information_page])
      flash[:notice] = 'InformationPage was successfully updated.'
      redirect_to :action => 'show', :id => @information_page
    else
      render :action => :edit
    end
  end

  def destroy
    InformationPage.find(params[:id]).destroy
    redirect_to :controller => :news, :action => :index
  end

  private

  def load_images
    @images = Image.published.images.select('id, name').all
  end

  def set_revised_at_param
    unless params[:information_page].nil? || params[:information_page][:revised_at].blank?
      params[:information_page][:revised_at] = Time.now
    end
  end

end
