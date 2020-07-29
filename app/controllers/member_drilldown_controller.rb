# frozen_string_literal: true

require 'simple_drilldown/drilldown_controller'

class MemberDrilldownController < SimpleDrilldown::DrilldownController
  #   before_action { @content_width = 1024 }
  #
  #   # What fields should be displayed as default when listing actual Member records.
  #   default_fields %w[name created_at updated_at] # TODO(uwe): Read fields from schema?
  #
  #   # The main focus of the drilldown
  #   target_class Member # TODO(uwe): Infer from controller class name
  #
  #   # How should we count the reords?
  #   select 'count(*) as count'
  #
  #   # When listing records, what relations should be included for optimization?
  #   # list_includes :user, :comments # TODO(uwe): Read relations from schema?
  #
  #   # In what order should records be listed?
  #   list_order 'members.created_at'
  #
  #   # Field definitions when listing records
  field :created_at
  #   field :name
  #   field :updated_at
  #
  #   # The "attr_method" option transforms the value from the database to a
  #   # readable form.
  #   # field :member, attr_method: ->(post) { post.user.name }
  #   # field :body, attr_method: ->(post) { post.body[0..32] }
  #   # field :comments, attr_method: ->(post) { post.comments.count }
  #
  #   dimension :calendar_date, 'DATE(members.created_at)', interval: true
  #   dimension :day_of_month, "date_part('day', members.created_at)::int"
  #   dimension :day_of_week, <<~SQL, label_method: ->(day_no) { Date::DAYNAMES[day_no.to_i % 7] }
  #     CASE WHEN date_part('dow', members.created_at) = 0 THEN 7
  #       ELSE date_part('dow', members.created_at)::int END
  #   SQL
  #   dimension :hour_of_day, "date_part('hour', members.created_at)::int"
  #   dimension :month, "date_part('month', members.created_at)::int",
  #       label_method: ->(month_no) { Date::MONTHNAMES[month_no.to_i] }
  #   dimension :week, "date_part('week', members.created_at)::int"
  #   dimension :year, "date_part('year', members.created_at)::varchar"
  #
  #   # dimension :comments, 'SELECT count(*) FROM comments c WHERE c.user_id = users.id'
  #   # dimension :user, 'users.name', includes: :user
end
