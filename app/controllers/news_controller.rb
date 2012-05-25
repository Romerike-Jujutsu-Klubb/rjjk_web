class NewsController < ApplicationController
  before_filter :admin_required, :except => [ :index, :list, :show ]

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def list
    @news_items = NewsItem.current.all(:order => 'created_at DESC', :limit => 10)
  end

  def show
    @news_item = NewsItem.find(params[:id])
  end

  def new
    @news_item ||= NewsItem.new
    @images = Image.all(:conditions => "name NOT LIKE '%.MP4'", :select => 'id, name')
    render :action => :new
  end

  def create
    @news_item = NewsItem.new(params[:news_item])
    if @news_item.save
      flash[:notice] = 'NewsItem was successfully created.'
      redirect_to :action => :list
    else
      new
    end
  end

  def edit
    @news_item = NewsItem.find(params[:id])
    @images = Image.all(:conditions => "name NOT LIKE '%.MP4'", :select => 'id, name')
  end

  def update
    @news_item = NewsItem.find(params[:id])
    if @news_item.update_attributes(params[:news_item])
      flash[:notice] = 'NewsItem was successfully updated.'
      redirect_to :action => :list, :id => @news_item
    else
      render :action => :edit
    end
  end

  def expire
    n = NewsItem.find(params[:id])
    n.publication_state = NewsItem::PublicationState::EXPIRED
    n.expire_at ||= Time.now
    n.save!
    redirect_to :action => :list
  end

  def destroy
    NewsItem.find(params[:id]).destroy
    redirect_to :action => :list
  end

end
