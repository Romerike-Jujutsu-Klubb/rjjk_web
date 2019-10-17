# frozen_string_literal: true

json.extract! price_age_group, :id, :name, :from_age, :to_age, :yearly_fee, :monthly_fee, :created_at,
    :updated_at
json.url price_age_group_url(price_age_group, format: :json)
