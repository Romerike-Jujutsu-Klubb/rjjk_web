# frozen_string_literal: true

class CurriculumGroupsController < ApplicationController
  before_action :authenticate_user
  before_action :admin_required, except: %i[index show]
  before_action :set_curriculum_group, only: %i[show edit update destroy]

  def index
    @curriculum_groups = CurriculumGroup.all
  end

  def show
    @curriculum_group = CurriculumGroup.find(params[:id])
    @ranks = @curriculum_group.ranks.to_a
    return if instructor? || technical_committy?

    next_rank = current_user.member.next_rank
    @ranks.select! { |r| r.position <= next_rank.position }
  end

  def new
    @curriculum_group = CurriculumGroup.new
  end

  def edit; end

  def create
    @curriculum_group = CurriculumGroup.new(curriculum_group_params)
    if @curriculum_group.save
      redirect_to @curriculum_group, notice: 'Curriculum group was successfully created.'
    else
      render :new
    end
  end

  def update
    if @curriculum_group.update(curriculum_group_params)
      redirect_to @curriculum_group, notice: 'Curriculum group was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @curriculum_group.destroy
    redirect_to curriculum_groups_url, notice: 'Curriculum group was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_curriculum_group
    @curriculum_group = CurriculumGroup.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def curriculum_group_params
    params.fetch(:curriculum_group, {})
  end
end
