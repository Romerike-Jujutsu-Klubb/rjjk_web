# frozen_string_literal: true

class CurriculumsController < ApplicationController
  before_action :authenticate_user

  def index
    next_rank = current_user.member.next_rank
    @ranks = Rank.kwr
        .where('curriculum_groups.position < ?', next_rank.curriculum_group.position)
        .or(Rank.kwr
            .where('curriculum_groups.position = ?', next_rank.curriculum_group.position)
            .where('ranks.position <= ?', next_rank.position))
        .order(:'curriculum_groups.position', :'ranks.position').to_a
  end

  def card
    @rank = Rank.find(params[:id])
    render layout: 'print'
  end

  def card_pdf
    if (rank_id = params[:id])
      ranks = [Rank.find(rank_id)]
    else
      rank = current_user.member.next_rank
      ranks = rank.curriculum_group.ranks.select { |r| r.position <= rank.position }
    end
    filename = "Skill_Card_#{ranks.last.name}.pdf"
    send_data SkillCard.pdf(ranks.sort_by(&:position)),
        type: 'text/pdf', filename: filename, disposition: 'attachment'
  end

  def pdf
    @rank = Rank.find(params[:id])
    filename = "Pensum_#{@rank.name}.pdf"
    send_data CurriculumBook.pdf(@rank), type: 'text/pdf', filename: filename, disposition: 'attachment'
  end
end
