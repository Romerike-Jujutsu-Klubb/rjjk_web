class RanksController < ApplicationController
  USER_ACTIONS = [:card, :pdf, :pensum, :show]
  before_action :authenticate_user, only: USER_ACTIONS
  before_action :technical_committy_required, except: USER_ACTIONS

  def index
    @ranks = Rank.order(:martial_art_id, :position).to_a
    @martial_arts = @ranks.group_by(&:martial_art)
  end

  def pensum
    next_rank = current_user.member.next_rank
    @ranks = Rank.kwr.where('group_id = ? AND position <= ?',
        next_rank.group_id, next_rank.position).order(:position).to_a
  end

  def show
    @rank = Rank.find(params[:id])
  end

  def card
    @rank = Rank.find(params[:id])
    render layout: 'print'
  end

  def pdf
    @rank = current_user.member.next_rank
    filename = "Skill_Card_#{@rank.name}.pdf"
    send_data SkillCard.pdf(@rank.group.ranks
        .select { |r| r.position <= @rank.position }.sort_by(&:position)),
        type: 'text/pdf', filename: filename, disposition: 'attachment'
  end

  def new
    @rank ||= Rank.new
    @martial_arts = MartialArt.order(:name).to_a
    @groups = Group.order(:from_age).to_a
  end

  def create
    @rank = Rank.new(params[:rank])
    if @rank.save
      flash[:notice] = 'Rank was successfully created.'
      redirect_to action: :index
    else
      new
      render :action => 'new'
    end
  end

  def edit
    @rank ||= Rank.find(params[:id])
    @martial_arts = MartialArt.order(:name).to_a
    @groups = Group.order(:from_age).to_a
    render :edit
  end

  def update
    @rank = Rank.find(params[:id])
    if @rank.update_attributes(params[:rank])
      flash[:notice] = 'Rank was successfully updated.'
      back_or_redirect_to @rank
    else
      edit
    end
  end

  def destroy
    Rank.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
