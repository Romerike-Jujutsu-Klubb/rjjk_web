# frozen_string_literal: true
class SurveyRequestsController < ApplicationController
  USER_ACTIONS = [:answer_form, :save_answers, :thanks].freeze
  before_action :set_survey_request, only: [:show, :edit, :update, :destroy] + USER_ACTIONS
  before_action :authenticate_user, only: USER_ACTIONS
  before_action :admin_required, except: USER_ACTIONS

  def index
    @survey_requests = SurveyRequest.all
  end

  def show; end

  def new
    @survey_request = SurveyRequest.new
  end

  def edit; end

  def create
    @survey_request = SurveyRequest.new(survey_request_params)

    respond_to do |format|
      if @survey_request.save
        format.html do
          redirect_to @survey_request, notice: 'Survey request was successfully created.'
        end
        format.json { render :show, status: :created, location: @survey_request }
      else
        format.html { render :new }
        format.json { render json: @survey_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @survey_request.update(survey_request_params)
        format.html do
          redirect_to @survey_request, notice: 'Survey request was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @survey_request }
      else
        format.html { render :edit }
        format.json { render json: @survey_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey_request.destroy
    respond_to do |format|
      format.html do
        redirect_to survey_requests_url, notice: 'Survey request was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  def answer_form; end

  def save_answers
    params[:survey_request][:completed_at] = Time.current
    # params.require(:survey_request).
    #     permit(:comment, :completed_at,
    #     survey_answers_attributes: [:answer, :id, :survey_question_id])

    params[:survey_request][:survey_answers_attributes].each do |_i, values|
      logger.error "values: #{values.inspect}"
      free_text_answer = values.delete(:answer_free)
      logger.error "free_text_answer: #{free_text_answer.inspect}"
      values[:answer] = [*values[:answer], free_text_answer] if free_text_answer
    end

    if @survey_request.update(params[:survey_request])
      redirect_to action: :thanks
    else
      render :answer_form
    end
  end

  def thanks; end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_survey_request
    @survey_request = SurveyRequest.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def survey_request_params
    params.require(:survey_request).permit(:survey_id, :member_id, :completed_at)
  end
end
