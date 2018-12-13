# frozen_string_literal: true

class CurriculumsController < ApplicationController
  before_action :authenticate_user

  def index
    next_rank = current_user.member.next_rank
    @ranks = Rank.kwr.where('group_id = ? AND position <= ?',
        next_rank.group_id, next_rank.position).order(:position).to_a
  end

  def card
    @rank = Rank.find(params[:id])
    render layout: 'print'
  end

  def card_pdf
    @rank = current_user.member.next_rank
    filename = "Skill_Card_#{@rank.name}.pdf"
    send_data SkillCard.pdf(@rank.group.ranks
        .select { |r| r.position <= @rank.position }.sort_by(&:position)),
        type: 'text/pdf', filename: filename, disposition: 'attachment'
  end

  def pdf
    @rank = Rank.find(params[:id])
    filename = "Pensum_#{@rank.name}.pdf"
    send_data CurriculumBook.pdf(@rank), type: 'text/pdf', filename: filename, disposition: 'attachment'
  end
end
