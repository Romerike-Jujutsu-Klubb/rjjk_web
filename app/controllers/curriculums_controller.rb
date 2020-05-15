# frozen_string_literal: true

# FIXME(uwe): Rename to MyCurriculumController
class CurriculumsController < ApplicationController
  before_action :authenticate_user
  before_action :admin_required, except: %i[index show card_pdf]
  before_action :set_curriculum, only: %i[show]

  def index
    if admin? || instructor? || technical_committy?
      @curriculum_groups = CurriculumGroup.includes(:martial_art).references(:martial_arts)
          .where(martial_arts: { original_martial_art_id: nil }).order(:martial_art_id, :position).to_a
      render 'curriculum_groups/index'
    else
      next_rank = current_user.member.next_rank
      redirect_to next_rank.curriculum_group
    end
  end

  def show
    index
  end

  def card_pdf
    next_rank = current_user.member.next_rank
    ranks = next_rank.curriculum_group.ranks.select { |r| r.position <= next_rank.position }
    filename = "Skill_Card_#{ranks.last.name}.pdf"
    send_data SkillCard.pdf(ranks.sort_by(&:position)),
        type: 'text/pdf', filename: filename, disposition: 'attachment'
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
