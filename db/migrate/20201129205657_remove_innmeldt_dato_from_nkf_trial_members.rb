# frozen_string_literal: true

class RemoveInnmeldtDatoFromNkfTrialMembers < ActiveRecord::Migration[6.0]
  def change
    remove_column :nkf_member_trials, :innmeldtdato, :date
  end
end
