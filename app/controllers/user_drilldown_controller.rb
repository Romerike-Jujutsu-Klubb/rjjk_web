# frozen_string_literal: true

require 'simple_drilldown/drilldown_controller'

class UserDrilldownController < SimpleDrilldown::DrilldownController
  before_action { @content_width = 1024 }

  # What fields should be displayed as default when listing actual User records.
  default_fields %w[name created_at updated_at] # TODO(uwe): Read fields from schema?

  # The main focus of the drilldown
  target_class User

  # How should we count the reords?
  select 'count(*) as count'

  # When listing records, what relations should be included for optimization?
  # list_includes :user, :comments # TODO(uwe): Read relations from schema?

  # In what order should records be listed?
  list_order 'users.created_at'

  # Field definitions when listing records
  field :created_at
  field :name
  field :updated_at

  # The "attr_method" option transforms the value from the database to a
  # readable form.
  # field :user, attr_method: ->(post) { post.user.name }
  # field :body, attr_method: ->(post) { post.body[0..32] }
  # field :comments, attr_method: ->(post) { post.comments.count }

  dimension :calendar_date, 'DATE(users.created_at)', interval: true
  dimension :day_of_month, "date_part('day', users.created_at)"
  dimension :day_of_week,
      "CASE WHEN date_part('dow', users.created_at) = 0 THEN 7 ELSE date_part('dow', users.created_at) END",
      label_method: ->(day_no) { Date::DAYNAMES[day_no.to_i % 7] }
  dimension :deleted, 'deleted_at IS NOT NULL'
  dimension :hour_of_day, "date_part('hour', users.created_at)"
  dimension :month, "date_part('month', users.created_at)",
      label_method: ->(month_no) { Date::MONTHNAMES[month_no.to_i] }
  dimension :week, "date_part('week', users.created_at)"
  dimension :year, "date_part('year', users.created_at)"

  # dimension :comments, 'SELECT count(*) FROM comments c WHERE c.user_id = users.id'
  # dimension :user, 'users.name', includes: :user
end
