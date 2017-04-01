# frozen_string_literal: true
class NewsItemLikesController < ApplicationController
  before_action :set_news_item_like, only: [:show, :edit, :update, :destroy]

  def index
    @news_item_likes = NewsItemLike.all
  end

  def show; end

  def new
    @news_item_like = NewsItemLike.new
  end

  def edit; end

  def create
    @news_item_like = NewsItemLike.new(news_item_like_params)
    if @news_item_like.save
      redirect_to @news_item_like, notice: 'News item like was successfully created.'
    else
      render :new
    end
  end

  def update
    if @news_item_like.update(news_item_like_params)
      redirect_to @news_item_like, notice: 'News item like was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @news_item_like.destroy
    redirect_to news_item_likes_url, notice: 'News item like was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_news_item_like
    @news_item_like = NewsItemLike.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def news_item_like_params
    params.require(:news_item_like).permit(:news_item_id, :user_id)
  end
end
