# encoding: utf-8
class CreateSurveyQuestions < ActiveRecord::Migration
  def change
    create_table :survey_questions do |t|
      t.integer :survey_id, null: false
      t.integer :position, null: false
      t.string :title, null: false, limit: 254
      t.string :choices, limit: 254
      t.boolean :select_multiple
      t.boolean :free_text

      t.timestamps
    end
    reversible do |dir|
      dir.up do
        survey_id = Survey.first.id
        SurveyQuestion.create! survey_id: survey_id,
            title: 'Hvordan fikk du først vite om RJJK?',
            choices: "Avisannonse\nSøkemotor\nBekjent\nFamilie\nHusker ikke",
            free_text: true
        SurveyQuestion.create! survey_id: survey_id,
            title: 'På hvilke andre måter har du fått informasjon om klubben?',
            choices: "Avisannonse\nSøkemotor\nBekjent\nFamilie",
            free_text: true, select_multiple: true
        SurveyQuestion.create! survey_id: survey_id,
            title: 'Hva syns du om denne spørreundersøkelsen?  Dine tips er viktige for å forbedre klubbdriften.',
            free_text: true
      end
    end
  end
end
