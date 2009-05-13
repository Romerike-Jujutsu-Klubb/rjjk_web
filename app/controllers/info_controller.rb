class InfoController < ApplicationController
  before_filter :store_current_user_in_thread
  before_filter :store_location
  before_filter :admin_required, :except => [:index, :list, :show, :show_content]
  
  def index
    unless id = params[:id]
      id = InformationPage.find(:first, :order => 'id')
      unless id
        redirect_to :action => :new
        return
      end
    end
    redirect_to :action => :show, :id => id
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @information_pages = InformationPage.paginate :page => params[:page], :per_page => 10
  end

  def show
    @information_page ||= InformationPage.find_by_title(params[:id])
    @information_page ||= InformationPage.find_by_id(params[:id].to_i)
    raise "Unknown page" unless @information_page
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
    @images = Image.find(:all, :conditions => "name NOT LIKE '%.MP4'", :select => 'id, name')
  end

  def create
    @information_page = InformationPage.new(params[:information_page])
    if @information_page.save
      flash[:notice] = 'InformationPage was successfully created.'
      redirect_to :action => 'show', :id => @information_page
    else
      render :action => 'new'
    end
  end

  def rediger
    @information_page = InformationPage.find(params[:id])
    @images = Image.find(:all, :conditions => "name NOT LIKE '%.MP4'", :select => 'id, name')
  end

  def update
    @information_page = InformationPage.find(params[:id])
    if @information_page.update_attributes(params[:information_page])
      flash[:notice] = 'InformationPage was successfully updated.'
      redirect_to :action => 'show', :id => @information_page
    else
      render :action => 'rediger'
    end
  end

  def destroy
    InformationPage.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
end
