# frozen_string_literal: true

class EmbusController < ApplicationController
  before_action :authenticate_user

  def index
    if (embu = Embu.mine.last)
      redirect_to action: :edit, id: embu.id
    else
      redirect_to action: :new
    end
  end

  def show
    edit
  end

  def print
    @embu = Embu.mine.find(params[:id])
    render layout: 'print'
  end

  def new
    unless current_user.try(:member)
      redirect_to controller: :welcome, action: :index,
          notice: 'Du må være logget på og medlem for å redigere din embu.'
      return
    end
    @embu = Embu.new rank: current_user.member.next_rank
    load_data
  end

  def edit
    @embu = Embu.mine.find(params[:id])
    load_data
  end

  def create
    @embu = Embu.new(params[:embu].merge(user_id: current_user.id))
    if @embu.save
      redirect_to @embu, notice: 'Embu was successfully created.'
    else
      render action: :new
    end
  end

  def update
    @embu = Embu.mine.find(params[:id])
    if @embu.update_attributes(params[:embu])
      redirect_to action: :edit, id: @embu.id, notice: 'Embu was successfully updated.'
    else
      render action: :edit
    end
  end

  def destroy
    @embu = Embu.mine.find(params[:id])
    @embu.destroy
    redirect_to embus_url
  end

  private

  def load_data
    @embus = Embu.mine.where('user_id = ?', current_user.id).order('created_at DESC').to_a
    @ranks = Rank.order('position DESC').to_a
  end
end
