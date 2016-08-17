# frozen_string_literal: true
class CreateSurveyRequests < ActiveRecord::Migration
  def change
    create_table :survey_requests do |t|
      t.integer :survey_id, null: false
      t.integer :member_id, null: false
      t.text    :comment
      t.datetime :sent_at
      t.datetime :reminded_at
      t.datetime :completed_at

      t.timestamps
      t.index [:survey_id, :member_id], unique: true
    end
  end
end
