# frozen_string_literal: true

class CreateSurveyAnswers < ActiveRecord::Migration
  def change
    create_table :survey_answers do |t|
      t.integer :survey_request_id, null: false
      t.integer :survey_question_id, null: false
      t.string :answer, null: false, limit: 254

      t.timestamps
    end
  end
end
