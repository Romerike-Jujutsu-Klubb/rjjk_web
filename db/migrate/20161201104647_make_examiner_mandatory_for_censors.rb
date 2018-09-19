# frozen_string_literal: true

# Avoid NULL values for easier queries
class MakeExaminerMandatoryForCensors < ActiveRecord::Migration[4.2]
  def change
    reversible { |d| d.up { execute 'UPDATE censors SET examiner = false WHERE examiner IS NULL' } }
    change_column_null :censors, :examiner, false

    change_column :nkf_members, :foresatte_epost, :string, limit: 64
  end
end
