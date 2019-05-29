# frozen_string_literal: true

require File.dirname(__FILE__) + '/../test_helper'

class GraduationTest < ActiveSupport::TestCase
  test 'date cannot be changed after examiners/censors have confirmed' do
    g = graduations(:panda)
    g.censors.each { |c| c.locked_at = Time.current }
    assert_raise ActiveRecord::RecordInvalid do
      g.update! held_on: 2.days.from_now
    end
    assert_equal ['Dato kan ikke endres etter at graderingsoppsettet er låst'], g.errors.full_messages
  end
end
