# frozen_string_literal: true

class AddInvoiceEmailToNkfMemberTrials < ActiveRecord::Migration
  def self.up
    execute 'DELETE FROM nkf_member_trials'
    add_column :nkf_member_trials, :tid, :integer, null: false # rubocop:disable Rails/NotNullColumn
    add_column :nkf_member_trials, :epost_faktura, :string, limit: 64
    add_index :nkf_member_trials, :tid, unique: true
  end

  def self.down
    remove_column :nkf_member_trials, :epost_faktura
    remove_column :nkf_member_trials, :tid
  end
end
