# frozen_string_literal: true

class AddMailingTimestampsToInformationPage < ActiveRecord::Migration[4.2]
  def change
    add_column :information_pages, :revised_at, :datetime
    add_column :information_pages, :mailed_at, :datetime
  end
end
