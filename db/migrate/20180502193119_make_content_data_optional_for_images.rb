# frozen_string_literal: true

class MakeContentDataOptionalForImages < ActiveRecord::Migration[5.1]
  def change
    change_column_null :images, :content_data, true
  end
end
