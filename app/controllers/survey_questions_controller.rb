# frozen_string_literal: true

class SurveyQuestionsController < ApplicationController
  before_action :admin_required
  before_action :set_survey_question, only: %i(show edit update destroy)

  def index
    @survey_questions = SurveyQuestion.all
  end

  def show; end

  def new
    @survey_question = SurveyQuestion.new
    load_form_data
  end

  def load_form_data
    @surveys = Survey.order(:position).to_a
  end

  def edit
    load_form_data
  end

  def create
    @survey_question = SurveyQuestion.new(survey_question_params)

    respond_to do |format|
      if @survey_question.save
        format.html do
          redirect_to @survey_question, notice: 'Survey question was successfully created.'
        end
        format.json { render :show, status: :created, location: @survey_question }
      else
        format.html { render :new }
        format.json { render json: @survey_question.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @survey_question.update(survey_question_params)
        format.html do
          redirect_to @survey_question, notice: 'Survey question was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @survey_question }
      else
        format.html { render :edit }
        format.json { render json: @survey_question.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey_question.destroy
    respond_to do |format|
      format.html do
        redirect_to survey_questions_url, notice: 'Survey question was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_survey_question
    @survey_question = SurveyQuestion.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def survey_question_params
    params.require(:survey_question).permit(:survey_id, :title, :choices, :free_text)
  end
end
