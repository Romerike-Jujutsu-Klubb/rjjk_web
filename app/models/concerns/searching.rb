# frozen_string_literal: true

# Set up search by using SEARCH_FIELDS and TEXT_SEARCH_FIELDS
module Searching
  extend ActiveSupport::Concern

  class_methods do
    def search_scope(fields, text: nil, order: nil)
      scope :search, ->(query) do
        scope = where(fields.map { |f| "#{f} ~* :query" }.join(' OR '),
            query: query.split(/\s+/).map { |w| Regexp.escape w }.join('|'))

        if text
          ts_query = query.split(/\s+/).map { |t| %("#{t.tr('<->&!()', '')}") }.join(' | ')
          scope = scope.or(where(text.map { |c| "to_tsvector(#{c}) @@ to_tsquery(:query)" }.join(' OR '),
              query: ts_query))
        end

        scope = scope.order(order) if order

        scope
      end
    end
  end
end
