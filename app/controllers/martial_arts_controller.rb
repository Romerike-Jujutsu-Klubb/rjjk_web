# frozen_string_literal: true

class MartialArtsController < ApplicationController
  before_action :admin_required

  def index
    @martial_arts = MartialArt.all
  end

  def show
    edit
  end

  def new
    @martial_art ||= MartialArt.new
    render :new
  end

  def create
    @martial_art = MartialArt.new(params[:martial_art])
    if @martial_art.save
      flash[:notice] = 'MartialArt was successfully created.'
      redirect_to action: :index
    else
      new
    end
  end

  def copy
    original_martial_art = MartialArt.find(params[:id])
    martial_art = original_martial_art.deep_clone include: {
      curriculum_groups: { ranks: [:basic_techniques, {
        technique_applications: [{ application_image_sequences: :application_steps }, :application_videos],
      }] },
    }, validate: false do |original, copy|
      copy.name = "#{original.name} #{Date.current.strftime('%F %R')}" if copy.is_a?(MartialArt)
      raise "Invalid original: #{original.inspect}\n#{original.errors.full_messages}" if original.invalid?
    end

    if martial_art.save
      flash[:notice] = 'MartialArt was successfully created.'
      redirect_to edit_martial_art_path(martial_art)
    else
      redirect_to edit_martial_art_path(original_martial_art),
          alert: martial_art.errors.full_messages.join('  ')
    end
  end

  def edit
    @martial_art ||= MartialArt.find(params[:id])
    render :edit
  end

  def update
    @martial_art = MartialArt.find(params[:id])
    if @martial_art.update(params[:martial_art])
      flash[:notice] = 'MartialArt was successfully updated.'
      redirect_to action: 'show', id: @martial_art
    else
      edit
    end
  end

  def destroy
    MartialArt.find(params[:id]).destroy!
    redirect_to action: :index
  end
end
