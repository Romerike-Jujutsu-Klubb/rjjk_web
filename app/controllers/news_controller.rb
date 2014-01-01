class NewsController < ApplicationController
  before_filter :admin_required, :except => [ :index, :list, :show ]

  def index
    @news_items = NewsItem.front_page_items
    @link_to_news_archive = true
  end

  def list
    @news_items = NewsItem.order('created_at DESC').limit(30).includes(:creator => :member).all
    render :action => :index
  end

  def show
    @news_item = NewsItem.find(params[:id])
  end

  def new
    @news_item ||= NewsItem.new
    load_images
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
    load_images
  end

  def update
    @news_item = NewsItem.find(params[:id])
    if @news_item.update_attributes(params[:news_item])
      flash[:notice] = 'NewsItem was successfully updated.'
      back_or_redirect_to :action => :list, :id => @news_item
    else
      render :action => :edit
    end
  end

  def expire
    n = NewsItem.find(params[:id])
    n.publication_state = NewsItem::PublicationState::EXPIRED
    n.expire_at ||= Time.now
    n.save!
    back_or_redirect_to :action => :list
  end

  def destroy
    NewsItem.find(params[:id]).destroy
    back_or_redirect_to :action => :list
  end

  private

  def load_images
    @images = Image.published.images.select('id, name').order('created_at DESC').all
  end

end
