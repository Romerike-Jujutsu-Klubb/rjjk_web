# frozen_string_literal: true

require 'test_helper'

class CurriculumBookTest < ActiveSupport::TestCase
  test('pdf') { Rank.order(:position).each { |rank| assert CurriculumBook.pdf(rank) } }
end
