# frozen_string_literal: true
class AddRatingAndCommentToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :sent_review_email_at, :datetime
    add_column :attendances, :rating, :integer
    add_column :attendances, :comment, :string, limit: 250
  end
end
