class InfoController < ApplicationController
  before_filter :store_location
  before_filter :login_required, :except => [:show, :show_content, :sms, :kontakt]
  
  def index
    unless id = params[:id]
      id = InformationPage.find(:first)
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
    @information_page_pages, @information_pages = paginate :information_pages, :per_page => 10
  end

  def show
    @information_page = InformationPage.find(params[:id])
  end

  def show_content
    @information_page = InformationPage.find(params[:id])
    render :action => :show, :layout => false
  end

  def new
    @information_page = InformationPage.new
    @information_page.parent_id = params[:parent_id]
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
