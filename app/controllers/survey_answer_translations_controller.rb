# frozen_string_literal: true
class SurveyAnswerTranslationsController < ApplicationController
  before_action :admin_required
  before_action :set_survey_answer_translation, only: [:show, :edit, :update, :destroy]

  def index
    @survey_answer_translations = SurveyAnswerTranslation.all
  end

  def show; end

  def new
    @survey_answer_translation = SurveyAnswerTranslation.new
  end

  def edit; end

  def create
    @survey_answer_translation = SurveyAnswerTranslation.new(survey_answer_translation_params)

    respond_to do |format|
      if @survey_answer_translation.save
        format.html do
          redirect_to @survey_answer_translation,
              notice: 'Survey answer translation was successfully created.'
        end
        format.json { render :show, status: :created, location: @survey_answer_translation }
      else
        format.html { render :new }
        format.json do
          render json: @survey_answer_translation.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @survey_answer_translation.update(survey_answer_translation_params)
        format.html do
          redirect_to @survey_answer_translation,
              notice: 'Survey answer translation was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @survey_answer_translation }
      else
        format.html { render :edit }
        format.json do
          render json: @survey_answer_translation.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @survey_answer_translation.destroy
    respond_to do |format|
      format.html do
        redirect_to survey_answer_translations_url,
            notice: 'Survey answer translation was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_survey_answer_translation
    @survey_answer_translation = SurveyAnswerTranslation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def survey_answer_translation_params
    params.require(:survey_answer_translation).permit(:answer, :normalized_answer)
  end
end
