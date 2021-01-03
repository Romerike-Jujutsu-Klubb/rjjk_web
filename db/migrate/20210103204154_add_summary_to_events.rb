# frozen_string_literal: true

class AddSummaryToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :summary, :text
    add_column :events, :summary_en, :text
    Event.all.each do |e|
      paragraphs = e.description&.split(/\r?\n\r?\n/)
      summary = paragraphs&.first
      body = paragraphs&.drop(1)&.join("\n\n").presence

      paragraphs_en = e.description_en&.split(/\r?\n\r?\n/)
      summary_en = paragraphs_en&.first
      body_en = paragraphs_en&.drop(1)&.join("\n\n").presence

      e.update! summary: summary, description: body, summary_en: summary_en, description_en: body_en
    end
  end
end
