# frozen_string_literal: true

class AddDecorationToRanks < ActiveRecord::Migration
  def change
    add_column :ranks, :decoration, :string, limit: 16

    reversible do |dir|
      dir.up do
        Rank.order(:position).each do |rank|
          if rank.colour =~ %r{^(.*)\s+(m/.*)$}
            rank.update! colour: Regexp.last_match(1), decoration: Regexp.last_match(2)
          end
        end
      end
      dir.down do
        Rank.order(:position).each do |rank|
          rank.update! colour: "#{rank.colour} #{rank.decoration}}" if rank.decoration
        end
      end
    end
  end

  Rank = Class.new(ApplicationRecord)
end
