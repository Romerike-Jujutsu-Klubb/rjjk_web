# frozen_string_literal: true

class AddStandardTimeToRanks < ActiveRecord::Migration[4.2]
  def self.up
    add_column :ranks, :standard_months, :integer, null: true
    Rank.update_all standard_months: 6 # rubocop:disable Rails/SkipsModelValidations
    change_column :ranks, :standard_months, :integer, null: false
  end

  def self.down
    remove_column :ranks, :standard_months
  end

  class Rank < ApplicationRecord; end
end
