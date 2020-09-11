# frozen_string_literal: true

class MemberDrilldownController < SimpleDrilldown::Controller
  before_action { @content_width = 1024 }

  field :name
  field :joined_on
  default_fields %w[name joined_on]
  list_order 'members.joined_on, members.created_at'

  dimension :active, <<~SQL
    CASE
    WHEN left_on IS NOT NULL AND left_on < CURRENT_DATE THEN 'Utmeldt'
    WHEN honorary_on IS NOT NULL AND honorary_on < CURRENT_DATE THEN 'Æresmedlem'
    WHEN passive_on IS NOT NULL AND passive_on < CURRENT_DATE THEN 'Passiv'
    ELSE 'Aktiv'
    END
  SQL
  dimension :calendar_date, 'DATE(members.joined_on)', interval: true
  dimension :instructor, 'EXISTS(SELECT id FROM group_instructors WHERE member_id = members.id)',
      label_method: ->(bool) { bool ? 'Ja' : 'Nei' }
  dimension :month, "date_part('month', members.joined_on)::int",
      label_method: ->(month_no) { Date::MONTHNAMES[month_no.to_i] }
  dimension :week, "date_part('week', members.joined_on)::int"
  dimension :year, "date_part('year', members.joined_on)::varchar"
end
