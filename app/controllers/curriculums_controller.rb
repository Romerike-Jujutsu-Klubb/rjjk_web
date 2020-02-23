# frozen_string_literal: true

# FIXME(uwe): Split into MyCyrriculumController
class CurriculumsController < ApplicationController
  before_action :authenticate_user
  before_action :admin_required, except: %i[index show card_pdf]
  before_action :set_curriculum, only: %i[show edit update destroy]

  def index
    if admin? || instructor? || technical_committy?
      @curriculums = CurriculumGroup.order(:martial_art_id, :position).to_a
    else
      next_rank = current_user.member.next_rank
      redirect_to next_rank.curriculum_group
    end
  end

  def show
    @curriculum_group = CurriculumGroup.find(params[:id])
    @ranks = @curriculum_group.ranks.to_a
    return if instructor? || technical_committy?

    next_rank = current_user.member.next_rank
    @ranks.select! { |r| r.position <= next_rank.position }
  end

  def card_pdf
    next_rank = current_user.member.next_rank
    ranks = next_rank.curriculum_group.ranks.select { |r| r.position <= next_rank.position }
    filename = "Skill_Card_#{ranks.last.name}.pdf"
    send_data SkillCard.pdf(ranks.sort_by(&:position)),
        type: 'text/pdf', filename: filename, disposition: 'attachment'
  end

  def new
    @curriculum = CurriculumGroup.new
  end

  def edit; end

  def create
    @curriculum = CurriculumGroup.new(curriculum_params)
    if @curriculum.save
      redirect_to @curriculum, notice: 'Curriculum was successfully created.'
    else
      render :new
    end
  end

  def update
    if @curriculum.update(curriculum_params)
      redirect_to @curriculum, notice: 'Curriculum was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @curriculum.destroy
      flash.notice = 'Curriculum was successfully destroyed.'
    else
      flash.alert = "Kunne ikke slette pensumgruppen: #{@curriculum.errors.full_messages}"
    end
    redirect_to curriculums_url
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_curriculum
    @curriculum = CurriculumGroup.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def curriculum_params
    params.require(:curriculum).permit(:name, :martial_art_id, :position, :from_age, :to_age, :color)
  end
end
