# frozen_string_literal: true

class SurveysController < ApplicationController
  before_action :admin_required
  before_action :set_survey, only: %i[show edit update destroy]

  def index
    @surveys = Survey.all
  end

  def show; end

  def new
    @survey = Survey.new
  end

  def edit; end

  def create
    @survey = Survey.new(survey_params)

    respond_to do |format|
      if @survey.save
        format.html { redirect_to @survey, notice: 'Survey was successfully created.' }
        format.json { render :show, status: :created, location: @survey }
      else
        format.html { render :new }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @survey.update(survey_params)
        format.html { redirect_to @survey, notice: 'Survey was successfully updated.' }
        format.json { render :show, status: :ok, location: @survey }
      else
        format.html { render :edit }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey.destroy
    respond_to do |format|
      format.html { redirect_to surveys_url, notice: 'Survey was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_survey
    @survey = Survey.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def survey_params
    params.require(:survey)
        .permit(:category, :group_id, :title, :position, :expires_at, :header, :footer)
  end
end
