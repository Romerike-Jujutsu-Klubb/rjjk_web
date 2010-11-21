class MakeKontraktsbelopInteger < ActiveRecord::Migration
  def self.up
    change_column :nkf_members, :kontraktsbelop, :integer
  end

  def self.down
    change_column :nkf_members, :kontraktsbelop, :string
  end
end
