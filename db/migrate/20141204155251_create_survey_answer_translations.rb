# frozen_string_literal: true
class CreateSurveyAnswerTranslations < ActiveRecord::Migration
  def change
    create_table :survey_answer_translations do |t|
      t.string :answer, null: false, limit: 254
      t.string :normalized_answer, null: false, limit: 254

      t.timestamps
    end
  end
end
