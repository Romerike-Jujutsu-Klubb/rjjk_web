# frozen_string_literal: true
class AddDecorationToRanks < ActiveRecord::Migration
  def change
    add_column :ranks, :decoration, :string, limit: 16

    reversible do |dir|
      dir.up do
        Rank.order(:position).each do |rank|
          if rank.colour =~ %r{^(.*)\s+(m/.*)$}
            rank.update! colour: $1, decoration: $2
          end
        end
      end
      dir.down do
        Rank.order(:position).each do |rank|
          if rank.decoration
            rank.update! colour: "#{rank.colour} #{rank.decoration}}"
          end
        end
      end
    end
  end

  Rank = Class.new(ActiveRecord::Base)
end
