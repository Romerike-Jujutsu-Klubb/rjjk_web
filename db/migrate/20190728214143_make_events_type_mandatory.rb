class MakeEventsTypeMandatory < ActiveRecord::Migration[5.2]
  def change
    change_column_null :events, :type, true
  end
end
