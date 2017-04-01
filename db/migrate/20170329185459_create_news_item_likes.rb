# frozen_string_literal: true

class CreateNewsItemLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :news_item_likes do |t|
      t.references :news_item, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end

    # NewsItem.all.each do |ni|
    #   if ni.summary
    #    summary_doc = Kramdown::Document.new(ni.summary, input: :html, remove_span_html_tags: true)
    #     summary_doc.to_remove_html_tags
    #     summary = summary_doc.to_kramdown
    #   end
    #
    #   if ni.body
    #     body_doc = Kramdown::Document.new(ni.body, input: :html, remove_span_html_tags: true)
    #     body_doc.to_remove_html_tags
    #     body = body_doc.to_kramdown
    #   end
    #
    #   ni.update! summary: summary, body: body
    # end
  end

  # class NewsItem < ActiveRecord::Base
  # end
end
