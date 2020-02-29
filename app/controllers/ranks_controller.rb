# frozen_string_literal: true

class RanksController < ApplicationController
  USER_ACTIONS = %i[card pdf pensum show].freeze
  before_action :authenticate_user, only: USER_ACTIONS
  before_action :technical_committy_required, except: USER_ACTIONS

  def index
    ma_id = current_user.member.current_rank.martial_art_id
    @ranks = Rank.includes(:curriculum_group).references(:curriculum_groups)
        .order(:martial_art_id, :position).to_a.sort_by { |r| r.martial_art_id == ma_id ? 0 : 1 }
    @martial_arts = @ranks.group_by(&:martial_art)
  end

  def show
    @rank = Rank.find(params[:id])
  end

  def card
    @rank = Rank.find(params[:id])
    render layout: 'print'
  end

  def card_pdf
    ranks = [Rank.find(params[:id])]
    filename = "Skill_Card_#{ranks.last.name}.pdf"
    send_data SkillCard.pdf(ranks.sort_by(&:position)),
        type: 'text/pdf', filename: filename, disposition: 'attachment'
  end

  def pdf
    rank = Rank.find(params[:id])
    filename = "Pensum_#{rank.name}.pdf"
    send_data CurriculumBook.pdf(rank),
        type: 'text/pdf', filename: filename, disposition: 'attachment'
  end

  def new
    @rank ||= Rank.new
    load_form_data
  end

  def create
    @rank = Rank.new(params[:rank])
    if @rank.save
      flash[:notice] = 'Rank was successfully created.'
      redirect_to action: :index
    else
      new
      render action: 'new'
    end
  end

  def edit
    @rank ||= Rank.find(params[:id])
    load_form_data
    render :edit
  end

  def update
    @rank = Rank.find(params[:id])
    if @rank.update(params[:rank])
      flash[:notice] = 'Rank was successfully updated.'
      back_or_redirect_to @rank
    else
      edit
    end
  end

  def destroy
    Rank.find(params[:id]).destroy!
    redirect_to action: 'index'
  end

  private

  def load_form_data
    @martial_arts = MartialArt.order(:name).to_a
    @curriculum_groups = CurriculumGroup.order(:from_age).to_a
  end
end
