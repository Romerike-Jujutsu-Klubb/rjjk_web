# frozen_string_literal: true

class NewsController < ApplicationController
  before_action :admin_required, except: %i[index list show]

  def index
    @news_items = NewsItem.front_page_items
    @link_to_news_archive = true
  end

  def list
    @news_items = NewsItem.order('created_at DESC').limit(30).includes(creator: :member).to_a
    render action: :index
  end

  def show
    @news_item = NewsItem.find(params[:id])
  end

  def new
    @news_item ||= NewsItem.new(params[:image])
    load_images
    render action: :new
  end

  def preview
    @news_item = NewsItem.new(params[:news_item])
    @news_item.id = 42
    @news_item.created_at ||= Time.current
    @news_item.creator ||= current_user
    render action: :show, layout: false
  end

  def create
    @news_item = NewsItem.new(params[:news_item])
    if @news_item.save
      flash[:notice] = 'Nyheten ble opprettet.'
      redirect_to action: :list
    else
      new
    end
  end

  def edit
    @news_item ||= NewsItem.find(params[:id])
    load_images
    render :edit
  end

  def update
    @news_item = NewsItem.find(params[:id])
    if @news_item.update_attributes(params[:news_item])
      flash[:notice] = 'Nyheten ble oppdatert.'
      back_or_redirect_to action: :show, id: @news_item
    else
      edit
    end
  end

  def like
    news_item = NewsItem.find(params[:id])
    like = news_item.news_item_likes.where(user_id: current_user.id).first_or_initialize
    if like.persisted?
      like.destroy!
    else
      like.save!
    end
    redirect_back fallback_location: news_item
  end

  def expire
    n = NewsItem.find(params[:id])
    n.publication_state = NewsItem::PublicationState::EXPIRED
    n.expire_at ||= Time.current
    n.save!
    back_or_redirect_to action: :index
  end

  def move_to_top
    n = NewsItem.find(params[:id])
    n.publish_at = Time.current
    n.expire_at = nil if n.expire_at&.< Time.current
    if n.publication_state == NewsItem::PublicationState::EXPIRED
      n.publication_state = NewsItem::PublicationState::PUBLISHED
    end
    n.save!
    back_or_redirect_to action: :index
  end

  def destroy
    NewsItem.find(params[:id]).destroy
    back_or_redirect_to action: :index
  end

  private

  def load_images
    @images = Image.published.images.select(:id, :name).order(created_at: :desc).to_a
  end
end
