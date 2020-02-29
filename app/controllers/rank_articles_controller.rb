# frozen_string_literal: true

class RankArticlesController < ApplicationController
  before_action :set_rank_article, only: %i[show edit update destroy]

  def index
    @rank_articles = RankArticle.all
  end

  def show; end

  def new
    @rank_article ||= RankArticle.new(params[:rank_article])
    load_form_data
  end

  def edit
    load_form_data
  end

  def create
    @rank_article = RankArticle.new(rank_article_params)
    if @rank_article.save
      redirect_to edit_rank_path(@rank_article.rank), notice: <<~MESSAGE
        La til artikkel "#{@rank_article.information_page.title}" til grad "#{@rank_article.rank.label}"
      MESSAGE
    else
      new
      render :new
    end
  end

  def update
    if @rank_article.update(rank_article_params)
      redirect_to edit_rank_path(@rank_article.rank), notice: 'Oppdaterte artikkel for grad.'
    else
      render :edit
    end
  end

  def destroy
    @rank_article.destroy
    redirect_to rank_articles_url, notice: 'Rank article was successfully destroyed.'
  end

  private

  def load_form_data
    @ranks = Rank.order(:curriculum_group_id, :position).to_a
    @articles = InformationPage.order(:title).to_a
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_rank_article
    @rank_article = RankArticle.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def rank_article_params
    params.require(:rank_article).permit(:position, :rank_id, :information_page_id)
  end
end
