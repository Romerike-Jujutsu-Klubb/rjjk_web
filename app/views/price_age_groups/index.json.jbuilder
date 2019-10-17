# frozen_string_literal: true

json.array! @price_age_groups, partial: 'price_age_groups/price_age_group', as: :price_age_group
