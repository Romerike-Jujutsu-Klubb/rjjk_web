# frozen_string_literal: true

class ApplicationImageSequencesController < ApplicationController
  before_action :technical_committy_required, except: :show
  before_action :membership_required, only: :show
  before_action :set_application_image_sequence, only: %i[show edit update destroy]

  def index
    @application_image_sequences = ApplicationImageSequence.all
  end

  def show; end

  def new
    @application_image_sequence = ApplicationImageSequence.new
  end

  def edit; end

  def create
    @application_image_sequence = ApplicationImageSequence.new(application_image_sequence_params)

    if @application_image_sequence.save
      redirect_to @application_image_sequence,
          notice: 'Application image sequence was successfully created.'
    else
      render :new
    end
  end

  def update
    if @application_image_sequence.update(application_image_sequence_params)
      redirect_to @application_image_sequence,
          notice: 'Application image sequence was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @application_image_sequence.destroy
    redirect_to application_image_sequences_url,
        notice: 'Application image sequence was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_application_image_sequence
    @application_image_sequence = ApplicationImageSequence.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def application_image_sequence_params
    params.require(:application_image_sequence)
        .permit(:technique_application_id, :image_id, :position, :title)
  end
end
