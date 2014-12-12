class SurveyAnswersController < ApplicationController
  before_action :admin_required
  before_action :set_survey_answer, only: [:show, :edit, :update, :destroy]

  def index
    @survey_answers = SurveyAnswer.all
  end

  def show
  end

  def new
    @survey_answer = SurveyAnswer.new
  end

  def edit
  end

  def create
    @survey_answer = SurveyAnswer.new(survey_answer_params)

    respond_to do |format|
      if @survey_answer.save
        format.html { redirect_to @survey_answer, notice: 'Survey answer was successfully created.' }
        format.json { render :show, status: :created, location: @survey_answer }
      else
        format.html { render :new }
        format.json { render json: @survey_answer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @survey_answer.update(survey_answer_params)
        format.html { redirect_to @survey_answer, notice: 'Survey answer was successfully updated.' }
        format.json { render :show, status: :ok, location: @survey_answer }
      else
        format.html { render :edit }
        format.json { render json: @survey_answer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey_answer.destroy
    respond_to do |format|
      format.html { redirect_to survey_answers_url, notice: 'Survey answer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_survey_answer
      @survey_answer = SurveyAnswer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def survey_answer_params
      params.require(:survey_answer).permit(:survey_request_id, :survey_question_id, :answer)
    end
end
